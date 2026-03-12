require "spec_helper"

RSpec.describe RuboCop::Cop::Layout::MultilineMethodChain, :config do
  let(:cop_config) { { "MinChainLength" => 3 } }

  describe "offense detection" do
    it "registers an offense for a chain of exactly MinChainLength calls" do
      expect_offense(<<~RUBY)
        foo.bar.baz.qux
        ^^^^^^^^^^^^^^^ Method chain of 3 calls should be written on separate lines.
      RUBY
    end

    it "does not register an offense for a chain of MinChainLength - 1 calls" do
      expect_no_offenses(<<~RUBY)
        foo.bar.baz
      RUBY
    end

    it "does not register an offense for a chain of 1 call" do
      expect_no_offenses(<<~RUBY)
        foo.bar
      RUBY
    end

    it "registers an offense for a longer chain" do
      expect_offense(<<~RUBY)
        foo.bar.baz.qux.quux
        ^^^^^^^^^^^^^^^^^^^^ Method chain of 4 calls should be written on separate lines.
      RUBY
    end

    it "flags a chain starting from a constant" do
      expect_offense(<<~RUBY)
        User.where(active: true).order(:name).limit(10)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Method chain of 3 calls should be written on separate lines.
      RUBY
    end
  end

  describe "autocorrect" do
    it "splits a single-line chain onto separate lines" do
      expect_offense(<<~RUBY)
        foo.bar.baz.qux
        ^^^^^^^^^^^^^^^ Method chain of 3 calls should be written on separate lines.
      RUBY

      expect_correction(<<~RUBY)
        foo
          .bar
          .baz
          .qux
      RUBY
    end

    it "indents the split calls two spaces beyond the root receiver's column" do
      expect_offense(<<~RUBY)
        result = foo.bar.baz.qux
                 ^^^^^^^^^^^^^^^ Method chain of 3 calls should be written on separate lines.
      RUBY

      expect_correction(<<~RUBY)
        result = foo
                   .bar
                   .baz
                   .qux
      RUBY
    end

    it "preserves method arguments on the same line as their call" do
      expect_offense(<<~RUBY)
        User.where(active: true).order(:name).limit(10)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Method chain of 3 calls should be written on separate lines.
      RUBY

      expect_correction(<<~RUBY)
        User
          .where(active: true)
          .order(:name)
          .limit(10)
      RUBY
    end

    it "keeps a trailing block on the same line as its method" do
      expect_offense(<<~RUBY)
        foo.bar.baz.each { |x| x }
        ^^^^^^^^^^^^^^^^ Method chain of 3 calls should be written on separate lines.
      RUBY

      expect_correction(<<~RUBY)
        foo
          .bar
          .baz
          .each { |x| x }
      RUBY
    end
  end

  describe "safe navigation" do
    it "flags a safe navigation chain at or above MinChainLength" do
      expect_offense(<<~RUBY)
        foo&.bar&.baz&.qux
        ^^^^^^^^^^^^^^^^^^ Method chain of 3 calls should be written on separate lines.
      RUBY
    end

    it "preserves the &. operator when autocorrecting" do
      expect_offense(<<~RUBY)
        foo&.bar&.baz&.qux
        ^^^^^^^^^^^^^^^^^^ Method chain of 3 calls should be written on separate lines.
      RUBY

      expect_correction(<<~RUBY)
        foo
          &.bar
          &.baz
          &.qux
      RUBY
    end
  end

  describe "already multiline chains" do
    it "does not flag a chain already split across lines" do
      expect_no_offenses(<<~RUBY)
        foo
          .bar
          .baz
          .qux
      RUBY
    end

    it "does not flag a chain whose arguments span multiple lines" do
      expect_no_offenses(<<~RUBY)
        foo.bar(
          1, 2, 3
        ).baz.qux
      RUBY
    end
  end

  describe "configurable threshold" do
    let(:cop_config) { { "MinChainLength" => 4 } }

    it "does not flag a chain below the configured threshold" do
      expect_no_offenses(<<~RUBY)
        foo.bar.baz.qux
      RUBY
    end

    it "flags a chain at the configured threshold" do
      expect_offense(<<~RUBY)
        foo.bar.baz.qux.quux
        ^^^^^^^^^^^^^^^^^^^^ Method chain of 4 calls should be written on separate lines.
      RUBY
    end
  end
end
