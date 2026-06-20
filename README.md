**POSWEB 2026 - Infra** é um sistema web completo (end-to-end) que demonstra a integração de uma aplicação de gestão de pessoas com provisionamento automático de infraestrutura na nuvem (AWS) e pipeline de CI/CD contínuo.

<div align="center">
    
![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white)
![Python](https://img.shields.io/badge/python-3670A0?style=for-the-badge&logo=python&logoColor=ffdd54)
![Flask](https://img.shields.io/badge/flask-%23000.svg?style=for-the-badge&logo=flask&logoColor=white)
![MySQL](https://img.shields.io/badge/mysql-4479A1.svg?style=for-the-badge&logo=mysql&logoColor=white)
![HTML5](https://img.shields.io/badge/html5-%23E34F26.svg?style=for-the-badge&logo=html5&logoColor=white)
![CSS3](https://img.shields.io/badge/css-%231572B6.svg?style=for-the-badge&logo=css&logoColor=white)
![Nginx](https://img.shields.io/badge/nginx-%23009639.svg?style=for-the-badge&logo=nginx&logoColor=white)

</div>

**Objetivo**: Aplicar os conhecimentos aprendidos em sala, durante as aulas de Infraestrutura para Web - Pós Graduação em Desenvolvimento Web, no IFBA - Campus Vitória da Conquista.

**Entregáveis**: A infraestrutura provisionada conta com :
- Front-end web estático;
- Back-end com Flask;
- Banco de dados relacional;
- API para comunicação (back-end <-> banco de dados).

### 📖 Glossário de Tecnologias

| Tecnologia         | Versão  | Descrição                                                                                                                                               |
| ------------------ | ------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Terraform**      | **1.x** | **Ferramenta de Infraestrutura como Código (IaC). Declara e provisiona toda a rede, servidores, segurança e banco de dados na provedora em nuvem.**     |
| **AWS EC2**        | **—**   | **Amazon Elastic Compute Cloud. Máquina virtual Linux (Ubuntu) que hospeda os artefatos estáticos (Nginx) e o serviço dinâmico (Gunicorn).**            |
| **AWS RDS**        | **—**   | **Amazon Relational Database Service. Instância gerenciada do banco MySQL, desonerando a EC2 do processamento e garantindo disponibilidade dos dados.** |
| **GitHub Actions** | **—**   | **Serviço de orquestração de CI/CD. Automatiza as pipelines de deploy, injeta credenciais em tempo real e orquestra a máquina virtual remota.**         |
| Python             | 3.10+   | Linguagem de programação interpretada e de alto nível. Runtime da aplicação — toda a lógica do backend é executada sobre o interpretador.               |
| Flask              | 3.x     | Microframework web em Python. Provê o servidor HTTP, roteamento REST e tratamento das requisições JSON da API.                                          |
| Flask-MySQLdb      | —       | Extensão que conecta nativamente o Flask ao servidor de banco de dados MySQL para execução de queries (CRUD).                                           |
| Flask-CORS         | —       | Gerenciamento de Cross-Origin Resource Sharing. Permite que o frontend faça requisições cross-origin com segurança para a API.                          |
| Gunicorn           | —       | Servidor WSGI para produção. Roda como serviço no Linux (`systemd`), garantindo estabilidade e escalabilidade para a aplicação Flask.                   |
| MySQL              | 8.0     | Banco de dados relacional. Responsável pelo armazenamento transacional persistente dos registros de Pessoas na nuvem.                                   |
| HTML/JS            | —       | Stack base do Frontend. A interface é renderizada no client-side via DOM, e a comunicação com a API usa a `Fetch API` nativa do JavaScript.             |
| Bootstrap          | 5.3.0   | Framework CSS para construção ágil da interface de usuário, componentes estruturais, formulários e sistema responsivo de tabelas.                       |

## 🔄 Fluxo End-to-End (CI/CD)

O ciclo de vida da aplicação é totalmente automatizado através do GitHub Actions. A cada _push_ na branch `main`, a seguinte sequência é executada:

1. **Injeção de Credenciais** — As chaves de ambiente (`_USER_`, `_PASSWORD_`, `_API_ADDRESS_`, etc.) são substituídas nos códigos-fonte pelos valores armazenados de forma segura no GitHub Secrets via `sed` (comando Linux).
2. **Transferência de Arquivos** — O código do Backend (`myapi.py`) e Frontend (`index.html`) são enviados para a máquina EC2 via SCP (Secure Copy Protocol).
3. **Migração do Banco de Dados** — O script `db.sql` é enviado e executado remotamente na instância RDS AWS via comando `mysql`, criando ou atualizando a modelagem.
4. **Reinicialização** — O serviço nativo (`systemd`) da API Flask é reiniciado via acesso SSH para assumir as novas credenciais da injeção e o novo código.

## 🛠️ Instalação e Execução

O repositório é projetado para ser executado nativamente nos servidores da AWS.

### 1️⃣ Autenticação AWS

O Terraform necessita de credenciais programáticas para atuar na sua nuvem.

1. No painel do **IAM** da AWS, crie um usuário com **AdministratorAccess** (ou permissões para EC2/RDS/VPC) e gere uma **Access Key**.
2. Configure as credenciais no terminal que executará o Terraform:

```bash
export AWS_ACCESS_KEY_ID="sua-access-key"
export AWS_SECRET_ACCESS_KEY="sua-secret-key"
export AWS_DEFAULT_REGION="us-east-1"
```

Alternativamente, registre as credenciais via `aws configure` usando o AWS CLI.

### 2️⃣ Provisionar Infraestrutura (IaC)

Toda a arquitetura AWS é definida na pasta `iac/` usando **Terraform**. A máquina já nascerá com os softwares configurados via `user_data`.

```bash
cd iac
terraform init
terraform plan
terraform apply -auto-approve
```

Este comando irá criar de forma automatizada:

- Uma VPC isolada(usará a VPC padrão da sua conta) com os Security Groups da aplicação.
- Uma Instância EC2 (Ubuntu) já com Nginx, Python e o daemon da API habilitado.
- Um Banco de Dados RDS (MySQL).

### 3️⃣ Configurar GitHub Secrets

No seu repositório GitHub, navegue até **Settings > Secrets and variables > Actions** e cadastre as seguintes chaves de ambiente (obtidas após a execução do Terraform):

| Secret        | Descrição                                  |
| ------------- | ------------------------------------------ |
| `HOST`        | IP Público da máquina EC2                  |
| `USERNAME`    | Usuário de autenticação SSH (ex: `ubuntu`) |
| `KEY`         | Conteúdo da chave privada PEM de acesso    |
| `DB_HOST`     | Endpoint gerado pela AWS para o RDS        |
| `DB_USERNAME` | Usuário root do banco (`myapp_user`)       |
| `DB_PASSWORD` | Senha configurada na IaC (`myapp_passwd`)  |
| `DB_NAME`     | Nome do schema do banco (`myapp`)          |

### 4️⃣ Disparar o Deploy

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
