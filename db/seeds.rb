# Dados de exemplo para desenvolvimento e para a apresentacao.
# Rode com: bin/rails db:seed
#
# find_or_create_by! deixa o arquivo idempotente: rodar duas vezes nao duplica
# nada, so completa o que estiver faltando.

puts "Limpando pedidos antigos..."
Pedido.destroy_all

puts "Criando clientes..."
clientes = [
  { nome: "Ana Souza",     email: "ana.souza@exemplo.com",     telefone: "11988887777" },
  { nome: "Bruno Lima",    email: "bruno.lima@exemplo.com",    telefone: "11977776666" },
  { nome: "Carla Dias",    email: "carla.dias@exemplo.com",    telefone: "11966665555" },
  { nome: "Diego Martins", email: "diego.martins@exemplo.com", telefone: "11955554444" }
].map { |attrs| Cliente.find_or_create_by!(email: attrs[:email]) { |c| c.assign_attributes(attrs) } }

puts "Criando produtos..."
produtos = [
  { nome: "Teclado Mecanico",   descricao: "Teclado mecanico ABNT2 com switches marrons", preco: 289.90, estoque: 25 },
  { nome: "Mouse Sem Fio",      descricao: "Mouse optico 1600 DPI, conexao 2.4GHz",       preco: 129.90, estoque: 40 },
  { nome: "Monitor 24 pol",     descricao: "Monitor IPS Full HD 75Hz",                    preco: 899.00, estoque: 10 },
  { nome: "Headset Gamer",      descricao: "Headset com microfone e som surround 7.1",    preco: 249.50, estoque: 15 },
  { nome: "Webcam Full HD",     descricao: "Webcam 1080p com microfone embutido",         preco: 199.90, estoque: 8 }
].map { |attrs| Produto.find_or_create_by!(nome: attrs[:nome]) { |p| p.assign_attributes(attrs) } }

puts "Criando pedidos..."

# Pedido 1: dois produtos diferentes, mostrando o calculo do total
Pedido.create!(
  cliente: clientes[0],
  status: "pago",
  itens_attributes: [
    { produto_id: produtos[0].id, quantidade: 1 },
    { produto_id: produtos[1].id, quantidade: 2 }
  ]
)

# Pedido 2: um produto, quantidade maior
Pedido.create!(
  cliente: clientes[1],
  status: "pendente",
  itens_attributes: [
    { produto_id: produtos[2].id, quantidade: 1 }
  ]
)

# Pedido 3: mesmo cliente do pedido 1, para a rota /clientes/:id/pedidos
# ter mais de um resultado
Pedido.create!(
  cliente: clientes[0],
  status: "enviado",
  itens_attributes: [
    { produto_id: produtos[3].id, quantidade: 1 },
    { produto_id: produtos[4].id, quantidade: 3 }
  ]
)

puts ""
puts "Pronto!"
puts "  #{Cliente.count} clientes"
puts "  #{Produto.count} produtos"
puts "  #{Pedido.count} pedidos  (#{ItemPedido.count} itens)"
puts ""
Pedido.includes(:cliente, itens: :produto).find_each do |pedido|
  puts "  Pedido ##{pedido.id} - #{pedido.cliente.nome} - #{pedido.status} - R$ #{'%.2f' % pedido.total}"
  pedido.itens.each do |item|
    puts "      #{item.quantidade}x #{item.produto.nome} a R$ #{'%.2f' % item.preco_unitario} = R$ #{'%.2f' % item.subtotal}"
  end
end
