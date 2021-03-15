defmodule Pento.Catalog.Product do
  use Ecto.Schema
  import Ecto.Changeset

  schema "products" do
    field :description, :string
    field :name, :string
    field :sku, :integer
    field :unit_price, :float

    timestamps()
  end

  defp validate_price_decrease(changeset) do
    validate_change(changeset, :unit_price, fn _, _ ->
      if changeset.changes.unit_price > changeset.data.unit_price do
        [unit_price: "must be a price decrease"]
      else
        []
      end
    end)
  end

  @doc false
  def changeset(product, %{"unit_price" => _new_price}) do
    product
    |> validate_price_decrease()
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [:name, :description, :unit_price, :sku])
    |> validate_required([:name, :description, :unit_price, :sku])
    |> unique_constraint(:sku)
    |> validate_number(:unit_price, greater_than: 0.0)
  end
end
