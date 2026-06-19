# Azure Ephemeral Container App

Un mini-projet de portfolio qui démontre un cycle CI/CD Azure complet :

1. tests unitaires et construction du conteneur ;
2. authentification GitHub → Azure sans secret grâce à OIDC ;
3. création de l'infrastructure avec Terraform ;
4. publication de l'image dans Azure Container Registry ;
5. déploiement dans Azure Container Apps ;
6. test fonctionnel de l'URL publique ;
7. destruction systématique des ressources éphémères.

L'application est volontairement simple : une API Node.js sans dépendance externe, avec
les routes `/`, `/health` et `/api/info`.

## Architecture

```mermaid
flowchart LR
    GH["GitHub Actions<br/>OIDC"] --> TF["Terraform"]
    TF --> ACR["Azure Container Registry"]
    TF --> ID["Managed Identity"]
    TF --> ACA["Azure Container Apps"]
    ID -->|"AcrPull"| ACR
    ACR -->|"image OCI"| ACA
    TEST["Test fonctionnel HTTP"] --> ACA
    TEST --> DESTROY["terraform destroy"]
```

Le groupe de ressources est le seul élément permanent. Il sert de périmètre de sécurité
à l'identité GitHub Actions. Toutes les ressources qu'il contient sont créées puis
détruites à chaque exécution de déploiement.

## Compétences démontrées

- Infrastructure as Code avec Terraform ;
- conteneurisation Docker ;
- Azure Container Apps et Azure Container Registry ;
- identité managée et rôle `AcrPull` ;
- fédération OIDC GitHub Actions / Microsoft Entra ID ;
- tests unitaires, health check et test fonctionnel avec retry ;
- stratégie de nettoyage avec `if: always()` ;
- principe du moindre privilège grâce à un rôle limité au groupe de ressources.

## Exécution locale

Prérequis : Node.js 22 et Docker.

```bash
npm test
npm start
curl http://localhost:3000/health
docker build -t azure-ephemeral-app .
docker run --rm -p 3000:3000 azure-ephemeral-app
```

## Configuration Azure et GitHub

Connectez-vous d'abord avec Azure CLI :

```bash
az login
az account set --subscription "<subscription-id>"
```

Depuis Git Bash ou WSL, lancez ensuite :

```bash
./scripts/bootstrap-azure.sh \
  --github-repository "mon-compte/mon-repo" \
  --resource-group "rg-github-portfolio" \
  --location "francecentral"
```

Le script crée :

- le groupe de ressources permanent ;
- une application Microsoft Entra et son service principal ;
- une fédération OIDC limitée à la branche `main` ;
- un rôle `Contributor` limité au groupe de ressources.

Il affiche les trois valeurs à enregistrer dans **Settings → Secrets and variables →
Actions → Variables** :

- `AZURE_CLIENT_ID`
- `AZURE_TENANT_ID`
- `AZURE_SUBSCRIPTION_ID`

Ajoutez également :

- `AZURE_RESOURCE_GROUP` : par exemple `rg-github-portfolio`
- `AZURE_LOCATION` : par exemple `francecentral`

Ces valeurs ne sont pas des secrets. Le workflow n'utilise aucun mot de passe Azure.

## Déclenchement

- une pull request exécute uniquement la CI locale et la validation Terraform ;
- un push sur `main` exécute le cycle Azure complet ;
- `workflow_dispatch` permet de lancer une démonstration manuellement.

Le job Azure est protégé par l'environnement GitHub `azure-demo`. Vous pouvez ajouter
une approbation manuelle dans les règles de cet environnement.

## Coût et nettoyage

Le workflow utilise de petites ressources et les détruit après le test. Azure Container
Registry est facturé tant qu'il existe ; ne supprimez donc pas l'étape de nettoyage.
En cas d'annulation brutale d'un runner, vérifiez le groupe de ressources et supprimez
les ressources restantes avant une nouvelle démonstration.

## Structure

```text
.
├── app/                         # API Node.js
├── infra/
│   ├── platform/                # ACR, environnement, identité et rôle
│   └── application/             # Azure Container App
├── scripts/
│   ├── bootstrap-azure.sh       # configuration OIDC initiale
│   └── functional-test.sh       # test de l'URL déployée
└── .github/workflows/ci-cd.yml
```

