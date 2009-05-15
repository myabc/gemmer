require 'rubygems'
Gem::manage_gems
require 'rake/gempackagetask'
require 'rake/testtask'
require 'rake/rdoctask'
require 'active_support'

def gemmer(gem_name)
  spec = eval(File.read("#{gem_name}.gemspec"))
 
  Rake::GemPackageTask.new(spec) do |pkg|
    pkg.need_tar = true
  end

  desc 'Test the gem.'
  task :test do
    Dir["test/*.rb"].each do |test|
      puts `ruby #{test}`
    end
  end

  package = "pkg/#{gem_name}-#{spec.version}.gem"

  desc "Build gem"
  task :default => "pkg/#{gem_name}-#{spec.version}.gem" do
    puts "generated latest version"
  end

  desc "Release gem"
  task :release => package do
    system "scp #{package} deploy@dev01.berlin.imedo.de:~/gems"
    system "ssh deploy@dev01.berlin.imedo.de 'cd ~/gems; sudo gem install --no-ri #{File.basename(package)}'"
  end

  desc "Generate documentation for #{gem_name}."
  Rake::RDocTask.new(:rdoc) do |rdoc|
    rdoc.rdoc_dir = 'rdoc'
    rdoc.title    = gem_name
    rdoc.options << '--line-numbers' << '--inline-source'
    rdoc.rdoc_files.include('README.rdoc')
    rdoc.rdoc_files.include('src/**/*.rb')
  end

  desc "Generate .gemspec file from .gemspec.erb file"
  task :gemspec do
    require 'erb'
    File.open("#{gem_name}.gemspec", 'w') do |file|
      file.puts ERB.new(File.read("#{gem_name}.gemspec.erb")).result
    end
  end
end
