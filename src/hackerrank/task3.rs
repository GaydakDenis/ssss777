pub fn staircase(n: usize) -> Vec<String> {
    let mut result = Vec::new();

    for i in 1..=n {
        let spaces = " ".repeat(n - i);
        let hashes = "#".repeat(i);
        let line = format!("{}{}", spaces, hashes);
        result.push(line);
    }

    result
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_staircase_4() {
        let expected = vec![
            "   #".to_string(),
            "  ##".to_string(),
            " ###".to_string(),
            "####".to_string(),
        ];
        assert_eq!(staircase(4), expected);
    }
}
