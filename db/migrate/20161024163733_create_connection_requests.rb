class CreateConnectionRequests < ActiveRecord::Migration[5.0]
  def change
    create_table :connection_requests do |t|
      t.integer    :status, default: 0
      t.belongs_to :sender
      t.belongs_to :receiver
      t.boolean    :accepted, default: false
      t.timestamps
    end
  end
end
