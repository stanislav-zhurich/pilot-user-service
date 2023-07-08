data "azurerm_user_assigned_identity" "aks_user_identity" {
  name                = "${var.environment}_aks_user_identity"
  resource_group_name = "${var.environment}_resource_group"
}
data "azurerm_kubernetes_cluster" "kubernetes_cluster" {
  name                = "${var.environment}_cluster"
  resource_group_name = "${var.environment}_resource_group"
}

data "azurerm_servicebus_topic_authorization_rule" "user_topic_auth_rule" {
  name                = var.servicebus_user_topic_auth_rule
  resource_group_name = "${var.environment}_resource_group"
  namespace_name      = "${var.environment}pilotappservicebus"
  topic_name          = var.servicebus_user_topic_name
}

data "azurerm_servicebus_topic" "user_servicebus_topic" {
  name                = "user_topic"
  resource_group_name = "${var.environment}_resource_group"
  namespace_name      = "${var.environment}pilotappservicebus"
}

provider "kubernetes" {
    host = data.azurerm_kubernetes_cluster.kubernetes_cluster.kube_admin_config.0.host
    client_certificate     = base64decode(data.azurerm_kubernetes_cluster.kubernetes_cluster.kube_admin_config.0.client_certificate)
    client_key             = base64decode(data.azurerm_kubernetes_cluster.kubernetes_cluster.kube_admin_config.0.client_key)
    cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.kubernetes_cluster.kube_admin_config.0.cluster_ca_certificate)
    experiments {
        manifest_resource = true
    }
}

resource "azurerm_servicebus_subscription" "keda_servicebus_subscription" {
  name               = "keda-user-topic-subscription"
  topic_id           = data.azurerm_servicebus_topic.user_servicebus_topic.id
  max_delivery_count = 3
}

resource "kubernetes_manifest" "keda-userservice-topic-secret" {
  manifest = {
    apiVersion = "v1"
    kind       = "Secret"

    metadata = {
      name = "pilot-user-service-topic-namespace-secret"
      namespace = "default"
    }
	
    type = "Opaque"
    
    data = {
      connection = base64encode(data.azurerm_servicebus_topic_authorization_rule.user_topic_auth_rule.primary_connection_string)
    }
  }
}

resource "kubernetes_manifest" "keda-userservice-trigger-authentication" {
  manifest = {
    apiVersion = "keda.sh/v1alpha1"
    kind       = "TriggerAuthentication"

    metadata = {
      name = "pilot-user-service-servicebus-auth"
      namespace  = "default"
    }
	
    spec = {
      secretTargetRef = [
        {
          key = "connection"
          name = "pilot-user-service-topic-namespace-secret"
          parameter = "connection"
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "keda-userservice-scaled-object" {
  manifest = {
    apiVersion = "keda.sh/v1alpha1"
    kind       = "ScaledObject"

    metadata = {
      name = "pilot-user-service-autoscaling"
      namespace  = "default"
    }
	
    spec = {
      scaleTargetRef = {
        name = "pilot-user-service"
      }
      minReplicaCount = 1
      maxReplicaCount = 4
      pollingInterval = 1
      cooldownPeriod = 5
      triggers = [
        {
          type = "azure-servicebus"
          metadata = {
            subscriptionName = azurerm_servicebus_subscription.keda_servicebus_subscription.name
            namespace = "${var.environment}pilotappservicebus"
            topicName = var.servicebus_user_topic_name
            messageCount = "5"
            activationMessageCount = "2"
            cloud = "AzurePublicCloud"
          }
          authenticationRef = {
            name = "pilot-user-service-servicebus-auth"
          }
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "aks_service_account" {
   manifest = {
    apiVersion = "v1"
    kind       = "ServiceAccount"

    metadata = {
      annotations = {
			"azure.workload.identity/client-id" = azurerm_user_assigned_identity.aks_user_identity.client_id
      }
      labels = {
        "azure.workload.identity/use" = true
      }
      name = "pilotserviceaccount"
      namespace = "default"
    }
  }
}

resource "azurerm_federated_identity_credential" "service_account_federated_identity" {
  name                = "pilot_service_account_federated_identity"
  resource_group_name = var.resource_group_name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = data.azurerm_kubernetes_cluster.kubernetes_cluster.oidc_issuer_url
  parent_id           = data.azurerm_user_assigned_identity.aks_user_identity.id
  subject             = "system:serviceaccount:default:pilotserviceaccount"
}