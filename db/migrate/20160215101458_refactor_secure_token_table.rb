class RefactorSecureTokenTable < ActiveRecord::Migration
  def change
    change_table :secure_tokens do |t|
      t.rename :token_id_hex, :uuid
      t.remove :target_id, :target_class
      t.references :target, polymorphic: true, index: true
    end
  end
end
