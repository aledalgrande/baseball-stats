module CharacterCheck
  extend ActiveSupport::Concern

  module ClassMethods
    def has_valid_characters?(*strings)
      encoding_options = { invalid: :replace, undef: :replace, replace: '', universal_newline: true }

      strings.each do |string|
        return false if !string.blank? && string.encode(Encoding.find('ASCII'), encoding_options).blank?
      end

      return true
    end
  end
end