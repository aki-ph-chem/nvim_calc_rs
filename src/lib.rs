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
                // handel 'Add'
                Messages::Add => {
                    let nums = values
                        .iter()
                        .map(|v| v.as_i64().unwrap())
                        .collect::<Vec<i64>>();
                    let sum = self.calculator.add(nums);

                    // echo response to Neovim
                    self.nvim
                        .command(&format!("echo \"Sum {}\"", sum.to_string()))
                        .unwrap();
                }
                // handel 'Multiply'
                Messages::Multiply => {
                    let mut nums = values.iter();
                    let p = nums.next().unwrap().as_i64().unwrap();
                    let q = nums.next().unwrap().as_i64().unwrap();
                    let product = self.calculator.multiply(p, q);

                    // echo response to Neovim
                    self.nvim
                        .command(&format!("echo \"Product: {}\"", product.to_string()))
                        .unwrap();
                }
                // handle anythin else
                Messages::Unknown(event) => {
                    // echo response to Neovim
                    self.nvim
                        .command(&format!("echo \"Unknown Command: {}\"", event))
                        .unwrap();
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
