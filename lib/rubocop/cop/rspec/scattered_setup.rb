# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks for separated hooks in the same example group.
      #
      # Unify `before`, `after`, and `around` hooks when possible.
      #
      # @example
      #   # bad
      #   describe Foo do
      #     before { setup1 }
      #     before { setup2 }
      #   end
      #
      #   # good
      #   describe Foo do
      #     before do
      #       setup1
      #       setup2
      #     end
      #   end
      #
      class ScatteredSetup < Cop
        include RuboCop::RSpec::TopLevelDescribe

        MSG = 'Do not define multiple hooks in the same example group.'.freeze

        # Selectors which indicate that indicate we should stop searching
        # for more hook definitions
        SCOPE_CHANGES = ExampleGroups::ALL + SharedGroups::ALL + Examples::ALL

        # @!method hook(node)
        #
        #   Detect if node is `before`, `after`, `around`
        def_node_matcher :hook, <<-PATTERN
        (block
          {
            $(send nil #{Hooks::ALL.node_pattern_union} (sym {:each :example}))
            $(send nil #{Hooks::ALL.node_pattern_union})
          }
        ...)
        PATTERN

        # @!method scope_change?(node)
        #
        #   Detect if the node is an example or a new example group
        #
        def_node_matcher :scope_change?, SCOPE_CHANGES.block_pattern

        def on_block(node)
          return unless example_group?(node)

          repeated =
            hooks_in_group(node)
              .group_by(&:method_name)
              .values
              .reject(&:one?)
              .flatten

          repeated.each do |repeated_hook|
            add_offense(repeated_hook, :expression)
          end
        end

        private

        def hooks_in_group(node, &block)
          return to_enum(__method__, node) unless block_given?

          node.each_child_node { |child| find_hooks(child, &block) }
        end

        def find_hooks(node, &block)
          return if scope_change?(node)

          hook(node, &block)
          hooks_in_group(node, &block)
        end
      end
    end
  end
end
