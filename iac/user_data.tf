# Define a leitura do script de inicialização da instância (user data).

# Renderiza o arquivo de template bash para ser injetado na EC2
data "template_file" "user_data" {
    template = file("templates/user_data.tpl")
}