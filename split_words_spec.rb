require 'rspec'
require './split_words'

describe SplitWords do
  let(:split_words) { SplitWords.new }

  before { populate_trie }

  describe '#use_word?' do
    subject { split_words.use_word?(current_word, next_word) }

    context 'when the current word is not a dictionary word' do
      let(:current_word) { 'madeup' }
      let(:next_word) { 'world' }

      it { should be_false }
    end

    context 'when the current word is a dictionary word' do
      let(:current_word) { 'hello' }

      context 'when the next word is nil' do
        let(:next_word) { nil }

        it { should be_true }
      end
    end
  end

  describe '#split' do
    subject { split_words.split(combined_word) }

    context 'for a single word' do
      let(:combined_word) { 'hello' }

      it 'returns the word' do
        expect(subject).to eql(['hello'])
      end
    end

    context 'for two distinct dictionary words' do
      let(:combined_word) { 'helloworld' }

      it 'returns an array of the split words' do
        expect(subject).to eql(['hello', 'world'])
      end
    end

    context 'for more than two distinct dictionary words' do
      let(:combined_word) { 'helloworldthiscanhandlemanywords' }

      it 'returns an array of the split words' do
        expect(subject).to eql(['hello', 'world', 'this', 'can', 'handle', 'many', 'words'])
      end
    end

    context 'for a combined word with more than one answer' do
      let(:combined_word) { 'backstop' }

      it 'returns an array of the least eagerly collected words' do
        expect(subject).to eql(['backs', 'top'])
      end
    end

    context 'for a combined word with multiple subwords but a single answer' do
      let(:combined_word) { 'mellowworld' }

      it 'returns an array of the valid words' do
        expect(subject).to eql(['mellow', 'world'])
      end
    end

    context "for a word that doesn't exist" do
      let(:combined_word) { 'hellomoon'}

      it 'raises an unknown word error' do
        expect { subject }.to raise_error('Unknown word moon')
      end
    end
  end

  def populate_trie
    %w[
      hello world this can handle many words
      back backs
      stop top
      mellow me
    ].each { |word| split_words.trie.add(word) }
  end
end
