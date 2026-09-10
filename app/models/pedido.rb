class Pedido < ApplicationRecord
  STATUS = %w[pendente pago enviado entregue cancelado].freeze

  belongs_to :cliente
  has_many :itens,
           class_name: "ItemPedido",
           inverse_of: :pedido,
           dependent: :destroy

  # Permite criar o pedido e seus itens numa unica requisicao.
  # reject_if descarta linhas vazias que o cliente da API mande por engano.
  accepts_nested_attributes_for :itens,
                                allow_destroy: true,
                                reject_if: ->(attrs) { attrs[:produto_id].blank? }

  validates :status, presence: true, inclusion: { in: STATUS }
  validate :deve_ter_ao_menos_um_item
  validate :nao_pode_repetir_produto

  # O total nunca vem da requisicao: e sempre recalculado a partir dos itens.
  before_save :calcular_total

  after_create :baixar_estoque_dos_produtos

  # dependent: :destroy apaga os itens ANTES do after_destroy do pedido rodar.
  # Por isso a lista precisa ser guardada antes, com prepend: true para este
  # callback correr na frente da remocao dos itens.
  before_destroy :guardar_itens_para_devolucao, prepend: true
  after_destroy :devolver_estoque_dos_produtos

  def calcular_total
    self.total = itens.reject(&:marked_for_destruction?).sum(&:subtotal)
  end

  private

  def deve_ter_ao_menos_um_item
    if itens.reject(&:marked_for_destruction?).empty?
      errors.add(:itens, "o pedido precisa ter ao menos um item")
    end
  end

  # A validacao de unicidade do ItemPedido consulta o banco, entao nao enxerga
  # duplicatas entre itens que ainda nao foram salvos. Aqui olhamos a lista
  # inteira em memoria, devolvendo 422 em vez de estourar o indice do banco.
  def nao_pode_repetir_produto
    ids = itens.reject(&:marked_for_destruction?).map(&:produto_id).compact
    repetidos = ids.tally.select { |_id, vezes| vezes > 1 }.keys
    return if repetidos.empty?

    nomes = Produto.where(id: repetidos).pluck(:nome).join(", ")
    errors.add(:itens, "produto repetido no mesmo pedido (#{nomes}). Use quantidade em vez de duas linhas")
  end

  # Roda dentro da transacao do save: se qualquer coisa falhar aqui,
  # o pedido inteiro e desfeito e nenhum estoque e alterado.
  def baixar_estoque_dos_produtos
    itens.each { |item| item.produto.baixar_estoque!(item.quantidade) }
  end

  def guardar_itens_para_devolucao
    @estoque_a_devolver = itens.map { |item| [ item.produto, item.quantidade ] }
  end

  def devolver_estoque_dos_produtos
    Array(@estoque_a_devolver).each do |produto, quantidade|
      produto.devolver_estoque!(quantidade)
    end
  end
end
