class CreateProdutos < ActiveRecord::Migration[8.1]
  def change
    create_table :produtos do |t|
      t.string :nome, null: false
      t.text :descricao
      # decimal com precisao definida: 10 digitos no total, 2 depois da virgula.
      # Nunca usar float para dinheiro (0.1 + 0.2 nao da 0.3 em ponto flutuante).
      t.decimal :preco, precision: 10, scale: 2, null: false
      t.integer :estoque, null: false, default: 0

      t.timestamps
    end

    add_check_constraint :produtos, "preco >= 0", name: "preco_nao_negativo"
    add_check_constraint :produtos, "estoque >= 0", name: "estoque_nao_negativo"
  end
end
