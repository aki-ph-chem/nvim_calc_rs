use nvim_calc_rs;

fn main() {
    let mut event_handler = nvim_calc_rs::EventHandler::new();

    event_handler.recv();
}
