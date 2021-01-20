
import stainless.annotation._
import stainless.collection._
import stainless.lang._
import stainless.lang.Option._
import stainless.lang.StaticChecks._
import stainless.proof.check

object MutListExample {
  final case class Node private (var value: BigInt, var nextOpt: Option[Node], @ghost var repr: List[AnyHeapRef]) extends AnyHeapRef {
    @ghost
    def valid: Boolean = {
      reads(repr.content ++ Set(this))
      decreases(repr.size)

      nextOpt match {
        case None() =>
          repr == List(this)
        case Some(next) =>
          repr.content.contains(next) &&
          repr == this :: next.repr &&
          repr.content == next.repr.content ++ Set(this) &&
          !next.repr.content.contains(this) &&
          next.valid
      }
    }

    def size: BigInt = {
      reads(repr.content ++ Set(this))
      require(valid)
      decreases(repr.size)

      nextOpt match {
        case None() => BigInt(1)
        case Some(next) => 1 + next.size
      }
    } ensuring (_ > 0)

    def last: Node = {
      reads(repr.content ++ Set(this))
      require(valid)
      decreases(size)

      nextOpt match {
        case None() => this
        case Some(next) => next.last
      }
    }

    def append(node: Node): Unit = {
      reads(repr.content ++ node.repr.content ++ Set(this, node))
      modifies(repr.content ++ Set(this))
      require(valid && node.valid && (repr.content & node.repr.content).isEmpty)
      decreases(size)

      nextOpt match {
        case None() =>
          nextOpt = Some(node)
          repr = this :: node.repr
        case Some(next) =>
          assert(next.valid)
          next.append(node)
          repr = this :: next.repr
          @ghost val unused = check(valid)
      }
    } ensuring { _ => valid }

    @allocates
    def prepend(newHead: BigInt): Unit = {
      reads(repr.content ++ Set(this))
      modifies(Set(this))
      require(valid && repr.forall(allocated(_))) // the forall is needed here, otherwise there is a counter-example
      
      val newNode = Node(value, nextOpt, Nil[AnyHeapRef])
      assert(!repr.contains(newNode)) // we would like to prove this, but can't :/
      newNode.repr = newNode :: repr.tail
      nextOpt = Some(newNode)
      value = newHead
      repr = this :: newNode.repr
    } ensuring { _ =>
      valid && nextOpt.isDefined && fresh(nextOpt.get)
    }
  }

  object Node {
    @allocates
    def apply(value: BigInt): Node = {
      val newNode = Node(value, None[Node], Nil[AnyHeapRef])
      newNode.repr = List(newNode)
      newNode
    } ensuring { res => fresh(res) && res.valid }
  }

  def readInvariant(l1: Node, l2: Node): Unit = {
    reads(l1.repr.content ++ l2.repr.content ++ Set(l1, l2))
    modifies(Set(l2))
    require(l1.valid && l2.valid && (l1.repr.content & l2.repr.content).isEmpty)
    val h1 = l1.value
    l2.value += 1
    val h2 = l1.value
    assert(h1 == h2)
  }
}