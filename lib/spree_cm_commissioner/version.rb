module SpreeCmCommissioner
  VERSION = '1.11.0-pre2'.freeze

  module_function

  # Returns the version of the currently loaded SpreeCmCommissioner as a
  # <tt>Gem::Version</tt>.
  def version
    Gem::Version.new VERSION
  end
end
