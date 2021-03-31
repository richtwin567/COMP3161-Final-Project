######  TYPES       ######
def decimal(digits_before_dot=None, digits_after_dot=None):
    if digits_after_dot and digits_after_dot:
        return f"DECIMAL({digits_before_dot}, {digits_after_dot})"
    elif not digits_before_dot and not digits_after_dot:
        return "DECIMAL"
    else:
        raise SyntaxError("Either both digits after dot must be specified or neither are specified")

def integer():
    return "INT"

def string(max=255):
    return f"VARCHAR({max})"

def enum(values):
    values = [ f"""'{value}'""" for value in values]
    return f"""ENUM({", ".join(values)})"""

######  END TYPES   ###### 


###### CONSTRAINTS  ######

def primary_key(field_names):
    return f"""PRIMARY KEY({", ".join(field_names)})"""

def foreign_key(field_name, ref_table, ref_field, cascade_on_delete=True, cascade_on_update=True):
    return f"""FOREIGN KEY({field_name}) REFERENCES {ref_table}({ref_field}) ON DELETE {"CASCADE" if cascade_on_delete else "RESTRICT"} ON UPDATE {"CASCADE" if cascade_on_update else "RESTRICT"}"""

def unique_key(field_names):
    return f"""UNIQUE KEY({", ".join(field_names)})"""

###### END CONSTRAINTS ######

def field(name,type, not_null=True, auto_increment=False):
    return f"""{name} {type}{" NOT NULL" if not_null else ""}{" AUTO_INCREMENT" if auto_increment else ""}"""

def create_table(table_name, fields, constraints):
    fields_constraints = ",\n\t".join(fields+constraints)
    return f"""
    CREATE TABLE {table_name} (
        {fields_constraints}
    );
    """




