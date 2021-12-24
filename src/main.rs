extern crate cap_std;

use std::env;
use std::io::{stdin, BufRead, BufReader, Error, Read};
use cap_std::ambient_authority;
use cap_std::fs::Dir;

use getopts::{Matches, Options};

const MAX_LENGTH: u64 = 128;

fn valid_query(query: &str) -> bool {
    return query
        .chars()
        .all(|c| c.is_alphanumeric() || matches!(c, '.' | '-' | '_'));
}

fn handle_query(base_dir: &Dir) -> Result<(), Error> {
    let mut query = String::new();
    let mut bstdin = BufReader::new(stdin().take(MAX_LENGTH));
    bstdin.read_line(&mut query)?;

    if query.contains("@") {
        println!("This server does not support remote fingering.");
        return Ok(());
    }

    let username = query.trim();

    if username == "" {
        println!("Nobody's online.");
        return Ok(());
    }

    if !valid_query(username) {
        println!("No funny business.");
       return Ok(());
    }

    let content = match base_dir.read_to_string(username) {
        Ok(c) => c,
        Err(_) => "No such user.".to_string(),
    };

    println!("{}", content);

    Ok(())
}

fn parse_options(args: &Vec<String>) -> Result<Matches, Error> {
    let mut opts = Options::new();
    opts.optopt("d", "base-dir", "set output file name", "NAME");
    opts.optflag("h", "help", "print this help menu");

    match opts.parse(&args[1..]) {
        Ok(m) => Ok(m),
        Err(e) => Err(Error::new(std::io::ErrorKind::Other, e.to_string())),
    }
}

fn main() -> Result<(), std::io::Error> {
    let args = env::args().collect();
    let options = parse_options(&args)?;

    if options.opt_present("h") {
        eprintln!("Usage: {} [--base-dir DIR]", args[0]);
        return Ok(());
    }

    let base_dir_path = match options.opt_str("d") {
        Some(dir) => dir,
        _ => "/var/lib/ringer".to_string(),
    };

    let base_dir = Dir::open_ambient_dir(base_dir_path, ambient_authority())?;

    match handle_query(&base_dir) {
        Ok(_) => (),
        _ => println!("No such user."),
    }

    Ok(())
}
