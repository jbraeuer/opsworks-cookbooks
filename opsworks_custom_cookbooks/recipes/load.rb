if node[:opsworks_custom_cookbooks][:enabled]
  if node["opsworks"]["always_update_cookbooks"] == true
    log "Always update cookbooks ENABLED"
    include_recipe "opsworks_custom_cookbooks::update"
  end
  if ["setup", "configure"].include? node["opsworks"]["activity"]
    log "Update cookbooks ENABLED for command #{node["opsworks"]["activity"]}"
    include_recipe "opsworks_custom_cookbooks::update"
  end
  include_recipe "opsworks_custom_cookbooks::checkout"
else
  directory node[:opsworks_custom_cookbooks][:destination] do
    action :delete
    recursive true

    only_if {node[:opsworks_custom_cookbooks][:destination]}
  end
end

ruby_block 'merge all cookbooks sources' do
  block do
     FileUtils.rm_rf Opsworks::InstanceAgent::Environment.merged_cookbooks_path
     FileUtils.cp_r Opsworks::InstanceAgent::Environment.default_cookbooks_path, Opsworks::InstanceAgent::Environment.merged_cookbooks_path
     FileUtils.cp_r "#{Opsworks::InstanceAgent::Environment.berkshelf_cookbooks_path}/.", Opsworks::InstanceAgent::Environment.merged_cookbooks_path if ::File.directory?(Opsworks::InstanceAgent::Environment.berkshelf_cookbooks_path)
     FileUtils.cp_r "#{Opsworks::InstanceAgent::Environment.site_cookbooks_path}/.", Opsworks::InstanceAgent::Environment.merged_cookbooks_path if ::File.directory?(Opsworks::InstanceAgent::Environment.site_cookbooks_path)
  end
end
