module AppDrone
class Template

  def initialize
    @drones = Hash.new{|h,k| h[k] = []}
    @directives = Hash.new{|h,k| h[k] = []}
    @drone_notices = Hash.new{|h,k| h[k] = []}
  end

  def add(ref,*params)
    klass = ref.is_a?(Class)? ref : ref.to_sym.to_app_drone_class
    @drones[klass] = klass.new(self, params.first) # no idea why `.first` is required..
  end

  def drone_objects; @drones.values end
  def drone_classes; @drones.keys end
  def drone_notices; @drone_notices end
  def hook?(klass); !(@drones[klass].nil? || @drones[klass] == []) end
  def hook(klass)
    raise "No such drone: #{klass}" unless i_klass = @drones[klass]
    return i_klass
  end
  
  def leftover_directives; @directives[:leftovers] end
  def generator_methods; @directives.keys - [:leftovers] end
  def overridable_generator_methods; [:gemfile] end
  def overridden_generator_method?(m); overridable_generator_methods.include?(m) end

  def do!(d,drone)
    generator_method = drone.class.generator_method || :leftovers
    @directives[generator_method] << d
  end

  def do_finally!(d,drone)
    @directives[:final] << d
  end

  def notify!(notice,drone)
    @drone_notices[drone.class] << notice.gsub("'","\\'").gsub('"','\\"') # escape quotes
  end
  
  def render!
    return if @rendered
    DependencyChain.check_dependencies!(drone_classes)

    ordered_chain = AppDrone::DependencyChain.sort(drone_classes)

    ordered_chain.each { |klass| hook(klass).align }
    ordered_chain.each { |klass| hook(klass).execute }

    @rendered = true
  end

  def render_with_wrapper
    render!
    template_path = '/template.erb'
    full_path = File.dirname(__FILE__) + template_path
    snippet = ERB.new File.read(full_path)
    return snippet.result(binding)
  end

  def render_to_screen
    render!
    puts render_with_wrapper
  end

  def render_to_file
    render!
    File.open('out.rb','w+') do |f|
      f.write(render_with_wrapper)
    end
  end
end
end
