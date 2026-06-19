pub fn kangaroo(x1: i32, v1: i32, x2: i32, v2: i32) -> &'static str {
    if v1 == v2 {
        if x1 == x2 { "YES" } else { "NO" }
    } else {
        let diff = x2 - x1;
        let step_diff = v1 - v2;
        if step_diff != 0 && diff % step_diff == 0 && diff / step_diff >= 0 {
            "YES"
        } else {
            "NO"
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_kangaroo() {
        assert_eq!(kangaroo(0, 3, 4, 2), "YES");
        assert_eq!(kangaroo(0, 2, 5, 3), "NO");
        assert_eq!(kangaroo(21, 6, 47, 3), "NO");
        assert_eq!(kangaroo(0, 2, 0, 2), "YES");
    }
}
