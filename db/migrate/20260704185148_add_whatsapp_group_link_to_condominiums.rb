class AddWhatsappGroupLinkToCondominiums < ActiveRecord::Migration[8.1]
  def change
    add_column :condominiums, :whatsapp_group_link, :string
  end
end
