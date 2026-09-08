class CreateClientes < ActiveRecord::Migration[8.1]
  def change
    create_table :clientes do |t|
      t.string :nome
      t.string :email
      t.string :telefone

      t.timestamps
    end
    add_index :clientes, :email, unique: true
  end
end
