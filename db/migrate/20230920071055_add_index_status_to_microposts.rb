class AddIndexStatusToMicroposts < ActiveRecord::Migration[5.2]
  def change
    change_column_null :microposts, :content, false
    change_column_null :microposts, :user_id, false
  end
end
