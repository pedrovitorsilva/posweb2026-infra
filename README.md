**POSWEB 2026 - People Management** é um sistema web completo (end-to-end) que demonstra a integração de uma aplicação de gestão de pessoas com provisionamento automático de infraestrutura na nuvem (AWS) e pipeline de CI/CD contínuo.

![Python](https://img.shields.io/badge/python-3670A0?style=for-the-badge&logo=python&logoColor=ffdd54)
![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white)
![Flask](https://img.shields.io/badge/flask-%23000.svg?style=for-the-badge&logo=flask&logoColor=white)

## 🔄 Fluxo End-to-End (CI/CD)

O ciclo de vida da aplicação é totalmente automatizado através do GitHub Actions. A cada *push* na branch `main`, a seguinte sequência é executada:

<div align="center">
  <p><sub>FLUXO DE DEPLOY</sub></p>
</div>

1. **Injeção de Credenciais** — As chaves de ambiente (`_USER_`, `_PASSWORD_`, `_API_ADDRESS_`, etc.) são substituídas nos códigos-fonte pelos valores armazenados de forma segura no GitHub Secrets via `sed`.
2. **Transferência de Arquivos** — O código do Backend (`myapi.py`) e Frontend (`index.html`) são enviados para a máquina EC2 via `scp`.
3. **Migração do Banco de Dados** — O script `db.sql` é enviado e executado remotamente na instância RDS AWS via comando `mysql`, criando ou atualizando a modelagem.
4. **Reinicialização** — O serviço nativo (`systemd`) da API Flask é reiniciado via acesso SSH para assumir as novas credenciais da injeção e o novo código.

## 🛠️ Instalação e Execução

O repositório é projetado para ser executado nativamente nos servidores da AWS.

### 1️⃣ Provisionar Infraestrutura (IaC)

Toda a arquitetura AWS é definida na pasta `iac/` usando **Terraform**. A máquina já nascerá com os softwares configurados via `user_data`.

```bash
cd iac
terraform init
terraform plan
terraform apply -auto-approve
```

Este comando irá criar de forma automatizada:
- Uma VPC isolada com os Security Groups da aplicação.
- Uma Instância EC2 (Ubuntu) já com Nginx, Python e o daemon da API habilitado.
- Um Banco de Dados RDS (MySQL).

### 2️⃣ Configurar GitHub Secrets

No seu repositório GitHub, navegue até **Settings > Secrets and variables > Actions** e cadastre as seguintes chaves de ambiente (obtidas após a execução do Terraform):

| Secret | Descrição |
| ------ | --------- |
| `HOST` | IP Público da máquina EC2 |
| `USERNAME` | Usuário de autenticação SSH (ex: `ubuntu`) |
| `KEY` | Conteúdo da chave privada PEM de acesso |
| `DB_HOST` | Endpoint gerado pela AWS para o RDS |
| `DB_USERNAME` | Usuário root do banco (`myapp_user`) |
| `DB_PASSWORD` | Senha configurada na IaC (`myapp_passwd`) |
| `DB_NAME` | Nome do schema do banco (`myapp`) |

### 3️⃣ Disparar o Deploy

Com os secrets preenchidos, basta realizar um push para a branch `main` ou disparar manualmente o workflow **Deploy MyAPP** na aba Actions do GitHub. A página web e a API estarão disponíveis acessando o IP Público da EC2 pelo navegador.

## 🗂️ Estruturação

```text
posweb2026-infra/
├── .github/
│   └── workflows/
│       └── deploy.yml
├── backend/
│   └── myapi.py
├── db/
│   └── db.sql
├── frontend/
│   └── index.html
└── iac/
    ├── db.tf
    ├── main.tf
    ├── sg.tf
    ├── user_data.tf
    ├── vpc.tf
    └── templates/
        └── user_data.tpl
```

### 📁 `.github/workflows/`
Configuração do pipeline. Contém o arquivo `deploy.yml` que orquestra o CI/CD usando `scp-action` e `ssh-action` para manipular a máquina virtual em nuvem sem intervenção manual.

### 📁 `backend/`
Código-fonte da API REST desenvolvida em **Python + Flask**, expondo rotas para as operações de CRUD (Create, Read, Update, Delete) com conexão persistente ao banco MySQL.

### 📁 `db/`
Script SQL (`db.sql`) utilizado para a modelagem do banco de dados (criação da tabela `People`). Ele é injetado diretamente no RDS na pipeline de CI/CD.

### 📁 `frontend/`
Aplicação Single Page (SPA) utilizando HTML, CSS (com framework Bootstrap) e manipulação do DOM em Vanilla JavaScript (`fetch` API) para exibir e manipular os dados consumidos do backend.

### 📁 `iac/`
Infraestrutura como Código (Terraform). Providencia de forma declarativa:
- Definição do Servidor Web EC2 (`main.tf`).
- Regras rígidas de rede e liberação de portas (`sg.tf` e `db.tf`).
- Criação e integração de Banco de Dados Gerenciado RDS MySQL (`db.tf`).
- Script Shell inicial (`user_data.tpl`), executado pelo sistema operacional recém-criado para configurar dependências (Nginx, MySQL-Client) e registrar a API Flask em background pelo `systemd`.