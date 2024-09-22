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

    /// Multiply all
    pub fn mul_all(&self, nums: Vec<i64>) -> i64 {
        nums.iter().fold(1, |mul_all, x| mul_all * x)
    }
}

/// event handler
pub struct EventHandler {
    nvim: Neovim,
    calculator: Calculator,
}

impl EventHandler {
    pub fn new() -> Self {
        let session = Session::new_parent().unwrap();
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
                // handel 'SumAll'
                Messages::SumAll => {
                    let nums = if let Some(rmpv::Value::Array(array)) = values.iter().next() {
                        array
                    } else {
                        panic!("Error: invalid data format");
                    };
                    let nums = nums
                        .iter()
                        .map(|v| v.as_i64().unwrap())
                        .collect::<Vec<i64>>();
                    let sum = self.calculator.add(nums);

                    // echo response to Neovim
                    self.nvim
                        .command(&format!("echo \"Sum {}\"", sum.to_string()))
                        .unwrap();
                }
                // handel 'Average'
                Messages::Average => {
                    let nums = if let Some(rmpv::Value::Array(array)) = values.iter().next() {
                        array
                    } else {
                        panic!("Error: invalid data format");
                    };
                    let nums = nums
                        .iter()
                        .map(|v| v.as_i64().unwrap())
                        .collect::<Vec<i64>>();
                    let n = nums.len();
                    let sum = self.calculator.add(nums) as f64 / n as f64;

                    // echo response to Neovim
                    self.nvim
                        .command(&format!("echo \"Average {}\"", sum.to_string()))
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
                // handel 'MulAll'
                Messages::MulAll => {
                    let nums = if let Some(rmpv::Value::Array(array)) = values.iter().next() {
                        array
                    } else {
                        panic!("Error: invalid data format");
                    };
                    let nums = nums
                        .iter()
                        .map(|v| v.as_i64().unwrap())
                        .collect::<Vec<i64>>();
                    let prod_all = self.calculator.mul_all(nums);

                    // echo response to Neovim
                    self.nvim
                        .command(&format!("echo \"Product All {}\"", prod_all.to_string()))
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
    SumAll,
    Average,
    MulAll,
    Unknown(String),
}

impl From<String> for Messages {
    fn from(event: String) -> Self {
        match &event[..] {
            "add" => Messages::Add,
            "multiply" => Messages::Multiply,
            "sum_all" => Messages::SumAll,
            "average" => Messages::Average,
            "mul_all" => Messages::MulAll,
            _ => Messages::Unknown(event),
        }
    }
}
