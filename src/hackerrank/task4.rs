pub fn grading_students(grades: Vec<u32>) -> Vec<u32> {
    grades.into_iter().map(|g| {
        if g >= 38 && g % 5 > 2 {
            g + (5 - g % 5)
        } else {
            g
        }
    }).collect()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_example() {
        let input = vec![73, 67, 38, 33];
        let expected = vec![75, 67, 40, 33];
        assert_eq!(grading_students(input), expected);
    }
}
