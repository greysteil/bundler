# frozen_string_literal: true
module Bundler
  class Source
    autoload :Gemspec,  "bundler/source/gemspec"
    autoload :Git,      "bundler/source/git"
    autoload :Metadata, "bundler/source/metadata"
    autoload :Path,     "bundler/source/path"
    autoload :Rubygems, "bundler/source/rubygems"

    attr_accessor :dependency_names

    def unmet_deps
      specs.unmet_dependency_names
    end

    def version_message(spec)
      message = "#{spec.name} #{spec.version}"
      message += " (#{spec.platform})" if spec.platform != Gem::Platform::RUBY && !spec.platform.nil?

      if Bundler.locked_gems
        locked_spec = Bundler.locked_gems.specs.find {|s| s.name == spec.name }
        locked_spec_version = locked_spec.version if locked_spec
        if locked_spec_version && spec.version != locked_spec_version
          message += Bundler.ui.add_color(" (was #{locked_spec_version})", version_color(spec.version, locked_spec_version))
        end
      end

      message
    end

    def can_lock?(spec)
      spec.source == self
    end

    # it's possible that gems from one source depend on gems from some
    # other source, so now we download gemspecs and iterate over those
    # dependencies, looking for gems we don't have info on yet.
    def double_check_for(*); end

    def include?(other)
      other == self
    end

    def inspect
      "#<#{self.class}:0x#{object_id} #{self}>"
    end

  private

    def version_color(spec_version, locked_spec_version)
      if Gem::Version.correct?(spec_version) && Gem::Version.correct?(locked_spec_version)
        # display yellow if there appears to be a regression
        earlier_version?(spec_version, locked_spec_version) ? :yellow : :green
      else
        # default to green if the versions cannot be directly compared
        :green
      end
    end

    def earlier_version?(spec_version, locked_spec_version)
      Gem::Version.new(spec_version) < Gem::Version.new(locked_spec_version)
    end
  end
end
