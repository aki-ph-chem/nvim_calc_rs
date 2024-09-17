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

    /// handle event
    pub fn recv(&mut self) {
        let receiver = self.nvim.session.start_event_loop_channel();

        for (event, values) in receiver {
            match Messages::from(event) {
                Messages::Add => {
                    // ToDo
                }
                Messages::Multiply => {
                    // ToDo
                }
                Messages::Unknown(event) => {
                    // ToDo
                }
            }
        }
    }
}

/// for handle message
pub enum Messages {
    Add,
    Multiply,
    Unknown(String),
}

impl From<String> for Messages {
    fn from(event: String) -> Self {
        match &event[..] {
            "add" => Messages::Add,
            "multiply" => Messages::Multiply,
            _ => Messages::Unknown(event),
        }
    }
}
