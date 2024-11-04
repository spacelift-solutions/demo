package spacelift

trigger[stack.id] { stack := input.stacks[_] }

sample := true