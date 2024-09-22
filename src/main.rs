use nvim_calc_rs;
use simplelog as slog;
use std::fs::File;

fn main() {
    let mut event_handler = nvim_calc_rs::EventHandler::new();
    // init logger
    let mut path_to_logfile = dirs::home_dir().unwrap();
    path_to_logfile.push(".nvim_calc.log");
    slog::CombinedLogger::init(vec![slog::WriteLogger::new(
        slog::LevelFilter::Info,
        slog::Config::default(),
        File::create(path_to_logfile.to_str().unwrap()).unwrap(),
    )])
    .unwrap();

    event_handler.recv();
}
