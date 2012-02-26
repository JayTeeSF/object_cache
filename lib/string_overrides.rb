module StringOverrides
  extend self

  def commence
    String.class_eval do
      def underscore
        self.gsub(/::/, '/').
          gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
          gsub(/([a-z\d])([A-Z])/,'\1_\2').
          tr("-", "_").
          downcase
      end
    end
  end
end
StringOverrides.commence
