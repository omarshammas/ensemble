class AddAttachmentImageToTasks < ActiveRecord::Migration
  def self.up
    change_table :tasks do |t|
      t.has_attached_file :image
    end
  end

  def self.down
    drop_attached_file :tasks, :image
  end
end
