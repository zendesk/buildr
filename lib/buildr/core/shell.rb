require 'buildr/shell'
require 'buildr/java/commands'

module Buildr
  module Shell
    class JIRB < Base
      SUFFIX = if Util.win_os? then '.bat' else '' end
      
      class << self
        def lang
          :none
        end
      end
      
      def launch
        fail 'Are we forgetting something? JRUBY_HOME not set.' unless jruby_home
        
        cp = project.compile.dependencies.join(File::PATH_SEPARATOR) + 
          File::PATH_SEPARATOR + project.path_to(:target, :classes)
        
        cp_var = ENV['CLASSPATH']
        if cp_var
          ENV['CLASSPATH'] += File::PATH_SEPARATOR
        else
          ENV['CLASSPATH'] = ''
        end
        ENV['CLASSPATH'] += cp
        
        system(File.expand_path('bin/jirb' + SUFFIX, jruby_home))
      end
      
    private
      def jruby_home
        @home ||= ENV['JRUBY_HOME']
      end
    end
    
    class Clojure < Base
      JLINE_VERSION = '0.9.94'
      
      class << self
        def lang
          :none
        end
        
        def to_sym
          :clj      # more common than `clojure`
        end
      end
      
      def launch
        fail 'Are we forgetting something? CLOJURE_HOME not set.' unless clojure_home
        
        cp = project.compile.dependencies + 
          [
            project.path_to(:target, :classes),
            File.expand_path('clojure.jar', clojure_home),
            'jline:jline:jar:0.9.94'
          ]
        
        Java::Commands.java 'jline.ConsoleRunner', 'clojure.lang.Repl', :classpath => cp
      end
      
    private
      def clojure_home
        @home ||= ENV['CLOJURE_HOME']
      end
    end
  end
end

Buildr::ShellProviders << Buildr::Shell::JIRB
Buildr::ShellProviders << Buildr::Shell::Clojure
