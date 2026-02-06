# 📜 Laboratoire : Architecture Cloud Sécurisée avec Azure Bicep

**Objectif :** Concevoir une infrastructure "Zero Trust" automatisée incluant un réseau privé, un serveur de calcul (VM) et une base de données PaaS (SQL) isolée.

---

## 🛠️ Rappel Technique

### Syntaxe Bicep

* **Déclaration de ressource :** `resource <nom-symbolique> '<type>@<version>' = { ... }`
* **Référence existante :** `resource kv '...' existing = { name: 'nom' }` (pour pointer une ressource créée manuellement).
* **Récupération de secret :** `kv.getSecret('nom-du-secret')`.

### Commandes Azure CLI

| Commande | Action |
| --- | --- |
| `az login` | Authentification au tenant Azure. |
| `az group create` | Création d'un groupe de ressources (contenant). |
| `az deployment group what-if` | Prévisualisation des changements (mode simulation). |
| `az deployment group create` | Exécution du déploiement Bicep. |

---

## 🏗️ EXERCICE 0 : Fondations de Sécurité (30 min)

*Objectif : Configurer manuellement le coffre-fort via l'interface graphique.*

1. **Groupe de Ressources :** Créez manuellement un groupe nommé `rg-lab-bicep-student`.
2. **Key Vault :** Créez un coffre nommé `kv-bicep-student-XXXX` (doit être unique au monde).
* **Configuration d'accès :** Dans l'onglet "Access Configuration", cochez la case **"Azure Resource Manager pour le déploiement de modèles"**.


3. **Secrets :** Créez deux secrets :
* `adminPassword` : Mot de passe pour la machine virtuelle.
* `sqlAdminPassword` : Mot de passe pour le serveur SQL.



---

## 🌐 EXERCICE 1 : Réseau et Points de Terminaison (1h30)

*Objectif : Préparer le pont privé entre le réseau et les services PaaS.*

**Tâche :** Créer un fichier `modules/network.bicep`.

* Déployez un VNet (`10.0.0.0/16`) avec un sous-réseau `snet-web` (`10.0.1.0/24`).
* **Service Endpoint :** Ajoutez la propriété `serviceEndpoints: [{ service: 'Microsoft.Sql' }]` sur le sous-réseau.
* **Output :** Exportez l'ID du sous-réseau (`subnetId`).

🔗 **Documentation :** [Service Endpoints - Bicep](https://learn.microsoft.com/fr-fr/azure/virtual-network/virtual-network-service-endpoints-overview)

---

## 💻 EXERCICE 2 : Calcul et Injection de Secrets (2h00)

*Objectif : Déployer une VM sans jamais manipuler de mot de passe en clair.*

**Tâche :** Créer un fichier `modules/compute.bicep`.

1. Utilisez le mot-clé `existing` pour référencer le Key Vault créé à l'exercice 0.
2. Déployez une interface réseau (NIC) liée au sous-réseau `snet-web`.
3. Déployez une VM `Standard_B1s` (Linux Ubuntu).
4. **Injection :** Assignez le mot de passe admin en utilisant `kv.getSecret('adminPassword')`.

🔗 **Documentation :** [Utiliser Key Vault avec Bicep](https://learn.microsoft.com/fr-fr/azure/azure-resource-manager/bicep/key-vault-parameter)

---

## 💾 EXERCICE 3 : SQL PaaS et Sécurisation VNet Rule (2h00)

*Objectif : Verrouiller la base de données pour qu'elle ne soit accessible QUE par la VM.*

**Tâche :** Créer un fichier `modules/sql.bicep`.

1. Déployez un serveur Azure SQL et une base de données (SKU : Basic).
2. **VNet Rule :** Déployez la ressource `Microsoft.Sql/servers/virtualNetworkRules`.
* Liez cette règle au serveur SQL.
* Passez-lui l'ID du sous-réseau `snet-web`.


3. **Vérification :** Désactivez l'option "Autoriser les services Azure" (`startIpAddress: 0.0.0.0`) pour tester l'étanchéité de votre règle VNet.

🔗 **Documentation :** [SQL Virtual Network Rules - Bicep](https://learn.microsoft.com/en-us/azure/templates/microsoft.sql/servers/virtualnetworkrules?pivots=deployment-language-bicep)

---

## 🚀 EXERCICE 4 : Orchestration et Déploiement (1h30)

*Objectif : Lier les modules et lancer l'infrastructure.*

**Tâche :**

1. Créez un fichier `main.bicep`.
2. Appelez les modules `network`, `compute` et `sql`.
3. Assurez-vous que l'output `subnetId` du réseau alimente les deux autres modules.
4. **Lancement :** Exécutez le déploiement via Azure CLI :
```bash
az deployment group create -g rg-lab-bicep-student -f main.bicep --parameters keyVaultName=kv-bicep-student-XXXX

```



---

## 🧪 EXERCICE 5 : Validation et Nettoyage (30 min)

1. **Audit :** Allez sur le portail Azure, section SQL Server > Networking. Vérifiez que votre sous-réseau est la seule source autorisée.
2. **Nettoyage :** Supprimez le groupe de ressources pour ne pas épuiser vos crédits :
```bash
az group delete --name rg-lab-bicep-student --yes --no-wait

```