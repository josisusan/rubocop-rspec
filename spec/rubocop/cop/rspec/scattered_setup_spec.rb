describe RuboCop::Cop::RSpec::ScatteredSetup do
  subject(:cop) { described_class.new }

  it 'flags multiple hooks in the same example group' do
    expect_violation(<<-RUBY)
      describe Foo do
        before { bar }
        ^^^^^^ Do not define multiple hooks in the same example group.
        before { baz }
        ^^^^^^ Do not define multiple hooks in the same example group.
      end
    RUBY
  end

  it 'does not flag different hooks' do
    expect_no_violations(<<-RUBY)
      describe Foo do
        before { bar }
        after { baz }
        around { qux }
      end
    RUBY
  end

  it 'does not flag hooks in different example groups' do
    expect_no_violations(<<-RUBY)
      describe Foo do
        before { bar }

        describe '.baz' do
          before { baz }
        end
      end
    RUBY
  end

  it 'does not flag hooks in different shared contexts' do
    expect_no_violations(<<-RUBY)
      describe Foo do
        shared_context 'one' do
          before { bar }
        end

        shared_context 'two' do
          before { baz }
        end
      end
    RUBY
  end

  it 'does not flag similar method names inside of examples' do
    expect_no_violations(<<-RUBY)
      describe Foo do
        before { bar }

        it 'uses an instance method called before' do
          expect(before { tricky }).to_not confuse_rubocop_rspec
        end
      end
    RUBY
  end

  it 'does not flag before(:all) and before(:each)' do
    expect_no_violations(<<-RUBY)
      describe Foo do
        before(:each) { example_setup }
        before(:all)  { global_setup  }
      end
    RUBY
  end
end
