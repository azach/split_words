require 'csv'
require 'rambling-trie'

class SplitWords
  class UnknownWordError < StandardError; end

  attr_reader :string, :trie

  def self.populate_trie(trie: trie, file_path: file_path)
    raise 'Invalid file' unless File.exists?(file_path)
    CSV.foreach(file_path, 'r') { |line| trie.add(line.first.downcase.strip) }
  end

  def initialize
    @trie = Rambling::Trie.create
  end

  def populate_trie(file_path)
    self.class.populate_trie(trie: @trie, file_path: file_path)
  end

  def use_word?(current_word_chars, remaining_word_chars)
    return false unless trie.word?(current_word_chars.join)
    return true if remaining_word_chars.none?
    next_word_chars = current_word_chars + [remaining_word_chars[0]]

    begin
      split(remaining_word_chars.join).any?
    rescue UnknownWordError
      !trie.partial_word?(next_word_chars.join)
    end
  end

  def split(combined_word)
    split_words         = []
    current_word_chars  = []
    combined_word_chars = combined_word.split('')

    combined_word_chars.each_with_index do |char, i|
      current_word_chars << char

      if use_word?(current_word_chars, combined_word_chars[i + 1..-1])
        split_words << current_word_chars.join
        current_word_chars.clear
      end
    end

    raise UnknownWordError.new("Unknown word #{current_word_chars.join}") if current_word_chars.any?

    split_words
  end
end
