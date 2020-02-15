# frozen_string_literal: true
# A number base for tokens.
# Compact, case-insensitive, alphanumeric, no ambiguous characters (0O or 1lI)
module Base31
  module_function

  NORMAL_ALPHABET = '0123456789abcdefghijklmnopqrstu'
  BASE31_ALPHABET = '23456789abcdefghjkmnpqrstuvwxyz'
  NORMALIZE_REGEX = /[^#{BASE31_ALPHABET}]*/.freeze

  def secure_random_str(length)
    raise ArgmentError unless length.is_a?(Integer) && length >= 1

    num = SecureRandom.random_number(31**length)
    to_s(num, length)
  end

  def to_i(base31)
    base31.to_s.downcase.tr(BASE31_ALPHABET, NORMAL_ALPHABET).to_i(31)
  end

  def to_s(integer, min_length = 1)
    raise ArgmentError unless integer.is_a?(Integer)
    raise ArgmentError unless min_length.is_a?(Integer)

    x = integer.to_s(31)
    x = x.rjust(min_length, '0') if min_length > 1
    x.tr(NORMAL_ALPHABET, BASE31_ALPHABET)
  end

  def normalize_s(base31)
    raise ArgumentError unless base31.is_a?(String)

    base31.downcase.gsub(NORMALIZE_REGEX, '')
  end

  # are two Base31 strings equivalent?
  def eq?(s1, s2)
    return false unless s1.is_a?(String)
    return false unless s2.is_a?(String)

    normalize_s(s1) == normalize_s(s2)
  end

  def display_token(base31, group_size = 0, separator = ' ')
    raise ArgumentError unless base31.is_a?(String)
    raise ArgumentError unless group_size.is_a?(Integer)
    raise ArgumentError unless separator.is_a?(String)

    x = base31.to_s.upcase
    x = x.gsub(/.{#{group_size}}(?!$)/, "\\0#{separator}") if group_size > 0 && !separator.empty?
    x
  end
end
