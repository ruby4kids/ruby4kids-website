namespace :deploy do

  desc "Create symlinks to stage-specific configuration files and shared assets"
  task :symlink, :except => { :no_release => true } do
    command = cleanup_targets.map { |target| "rm -fr #{current_path}/#{target}" }
    command += release_directories.map { |directory| "mkdir -p #{directory}" }
    command += release_symlinks.map { |from, to| "rm -fr #{current_path}/#{to} && ln -sf #{current_path}/#{from} #{current_path}/#{to}" }
    command += shared_symlinks.map { |from, to| "rm -fr #{current_path}/#{to} && ln -sf #{shared_path}/#{from} #{current_path}/#{to}" }
    run "cd #{current_path} && #{command.join(" && ")}"
  end

end
