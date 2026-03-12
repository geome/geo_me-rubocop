module RuboCop
  module Cop
    module Layout
      # Enforces that method chains with {MinChainLength} or more calls are
      # written on separate lines, one call per line.
      #
      # @example
      #   # bad
      #   foo.bar.baz.qux
      #
      #   # good
      #   foo
      #     .bar
      #     .baz
      #     .qux
      class MultilineMethodChain < Base
        extend AutoCorrector
        include RangeHelp

        MSG = "Method chain of %<length>d calls should be written on separate lines."

        def on_send(node)
          return unless outermost_send?(node)
          return unless node.single_line?

          length = chain_length(node)
          return if length < min_chain_length

          add_offense(node, message: format(MSG, length: length)) do |corrector|
            rewrite_chain(corrector, node)
          end
        end
        alias on_csend on_send

        private

        # Returns true only for the outermost call in a chain so we don't
        # report every intermediate node separately.
        def outermost_send?(node)
          parent = node.parent
          return true unless parent
          return true unless parent.send_type? || parent.csend_type?

          parent.receiver != node
        end

        # Counts how many consecutive send/csend calls make up the chain
        # starting from +node+ and walking down through receivers.
        def chain_length(node)
          length = 0
          current = node
          while (current.send_type? || current.csend_type?) && current.receiver
            length += 1
            current = current.receiver
          end
          length
        end

        def min_chain_length
          cop_config.fetch("MinChainLength", 3)
        end

        # Rewrites a single-line chain by placing each .method on its own
        # line, indented two spaces beyond the root receiver's column.
        def rewrite_chain(corrector, node)
          calls = collect_chain(node)
          indent = " " * (calls.last.loc.column + 2)

          calls.each do |call|
            dot = call.loc.dot
            next unless dot

            corrector.insert_before(dot, "\n#{indent}")
          end
        end

        # Returns all send nodes in the chain ordered from outermost to
        # innermost, stopping before the non-send root receiver.
        def collect_chain(node)
          chain = []
          current = node
          while (current.send_type? || current.csend_type?) && current.receiver
            chain << current
            current = current.receiver
          end
          chain
        end
      end
    end
  end
end
