use neovim_lib::{self, Neovim, NeovimApi, Session};

/// struct for calculator
pub struct Calculator;

impl Calculator {
    pub fn new() -> Self {
        Self {}
    }

    /// add a vector of numbers
    pub fn add(&self, nums: Vec<i64>) -> i64 {
        nums.iter().sum::<i64>()
    }

    /// Multiply two numbers
    pub fn multiply(&self, p: i64, q: i64) -> i64 {
        p * q
    }
}

/// event handler
pub struct EventHandler {
    nvim: Neovim,
    calculator: Calculator,
}

impl EventHandler {
    pub fn new() -> Self {
        let mut session = Session::new_parent().unwrap();
        let nvim = Neovim::new(session);
        let calculator = Calculator::new();

        Self { nvim, calculator }
    }
}
