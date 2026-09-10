# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_09_10_183343) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "clientes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.string "nome"
    t.string "telefone"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_clientes_on_email", unique: true
  end

  create_table "item_pedidos", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "pedido_id", null: false
    t.decimal "preco_unitario", precision: 10, scale: 2, null: false
    t.bigint "produto_id", null: false
    t.integer "quantidade", null: false
    t.datetime "updated_at", null: false
    t.index ["pedido_id", "produto_id"], name: "index_item_pedidos_on_pedido_id_and_produto_id", unique: true
    t.index ["pedido_id"], name: "index_item_pedidos_on_pedido_id"
    t.index ["produto_id"], name: "index_item_pedidos_on_produto_id"
    t.check_constraint "quantidade > 0", name: "quantidade_positiva"
  end

  create_table "pedidos", force: :cascade do |t|
    t.bigint "cliente_id", null: false
    t.datetime "created_at", null: false
    t.string "status", default: "pendente", null: false
    t.decimal "total", precision: 10, scale: 2, default: "0.0", null: false
    t.datetime "updated_at", null: false
    t.index ["cliente_id"], name: "index_pedidos_on_cliente_id"
  end

  create_table "produtos", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "descricao"
    t.integer "estoque", default: 0, null: false
    t.string "nome", null: false
    t.decimal "preco", precision: 10, scale: 2, null: false
    t.datetime "updated_at", null: false
    t.check_constraint "estoque >= 0", name: "estoque_nao_negativo"
    t.check_constraint "preco >= 0::numeric", name: "preco_nao_negativo"
  end

  add_foreign_key "item_pedidos", "pedidos"
  add_foreign_key "item_pedidos", "produtos"
  add_foreign_key "pedidos", "clientes"
end
