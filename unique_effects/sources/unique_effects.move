/// What id like to do is quite hard, I'm trying to make a list of 'UniqueEffect' that 
/// change the stat values in 'MyObj' by something other that just adding points think
/// change by percentage, swap 2 stats, etc.
/// 
/// Achieving this without a boat load of functions and not having to upgrade the package
/// every time i want a new effect will be hard. I can see 2 ways forward,
/// - first is a bunch of conditional logic, then parse some bytes through it.
///     this is still a bit restrictive.
/// - just parse some bytes and use something like UTF8 mappig to decypher what we want,
///     this one has more ??? around it.
/// - hmm, another one but this is BIG ??? is fk around with the byte code? probably should
///     know what im doing before attepting this, but that hasnt stop me before.
/// 
/// The solution is probably the first one...


/// These are a list of effect I want to be able to achieve.
/// + 10% energy.
/// + 25% rush, -30% energy.
/// flip power and rush, for both players.
/// if both power are equal? something (conditional logic...)


/// TO BE CLEAR! IF YOU'RE CONSIDERING THIS IN THERE OWN WORK, THIS COULD BE PROBABLIC
/// AND COULD LEAD TO EASLIY EXPLOITABLE HOLDS IN YOUR CODE. I AM A TRA... JUST BE CAREFUL!
/// this warning is for the bytes way of doing things 

module unique_effects::unique_effects {

    use std::string::{Self, String};
    use std::vector;

    // stats
    const ENERGY: u8 = 0;
    const POWER: u8 = 1;
    const RUSH: u8 = 2;

    // user
    const ME: u8 = 3;
    const OTHER: u8 = 4;
    const ALL: u8 = 5;

    // opperation
    const PERCENT: u8 = 6;
    const FLIP: u8 = 7;
    const SHIFT: u8 = 8;

    struct UniqueEffect has store, drop {
        op: u8,
        who: u8,
        stat1: u8,
        val1: u8,
        stat2: u8,
        val2: u8,
    }

    // this does rasie the question should stat be in a dynamic feild saved again a u8?
    struct MyObj has store, drop {
        energy: u64,
        power: u64,
        rush: u64,
    }

    public fun create_effect(op: u8, who: u8, stat1: u8, stat2: u8, val1: u8, val2: u8): UniqueEffect {
        UniqueEffect { op, who, stat1, stat2, val1, val2 }
    }

    public fun create_obj(energy: u64, power: u64, rush: u64): MyObj {
        MyObj {energy, power, rush}
    }

    // public fun 




}


// attempt 1 really didnt like this solution, going to try something that holds a lot of u8
// const refs that 

    // public fun update_stats(my_obj: MyObj, other_obj: MyObj, encoded: vector<u8>): (MyObj, MyObj) {
    //     let len = vector::length(encoded);
    //     let i = 0;
    //     while (i < len) {
    //         if (i == 0) {
    //             effect_who(vector::borrow(encoded, 0));
    //         };

    //         i = i + 1;
    //     };
    //     (obj, other_obj)
    // }

    // public fun effect_who(who: u8, my_obj: &MyObj, other_obj: &MyObj): &MyObj {
    //     if (who == "m") {
    //         my_obj
    //     } else if (who == b"o") {
    //         other_obj
    //     }
    // }


    // #[test]
    // public fun test_module_init() {
    //     let my_obj = create_obj( 3, 4, 5);
    //     let other_obj = create_obj( 3, 4, 5);
    //     assert!(obj.energy == 3, 0);
    //     // encoded: o = other, m = me, + = +
    //     let effect1 = create_effect(string::utf8(b"give me: + 10% energy"), b"m + 10 % 0");

    //     let obj = update_stats(my_obj, other_obj, effect1.encoded);
    // }
