from yaml import safe_load


def load_config(filepath: str) -> dict[list[dict]]:
    with open(filepath, "r") as file:
        return safe_load(file)
