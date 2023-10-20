-- title: Using Decision Tables in Elixir Applications - Part 1
-- date: 2023-10-19
-- tags: Elixir, Tablex, Decision Table

![decision making](/post-images/decision.png)

## Introduction

A [Decision Table][] is an intuitive tool for managing business rules. It serves as a visual representation of how various actions are determined based on different inputs. To better understand its application, consider an online bookstore that offers discounts to customers during the checkout process. The discount amount varies depending on the order amount and the customer's VIP level. Following is an example table that indicates how the final discount is calculated from user VIP level and order amount:

<style>
table.tablex {
  border: solid;
  border-spacing: 0;
}

table.tablex th, table.tablex td {
  text-transform: none;
  vertical-align: middle;
}

table.tablex col.output {
  background-color: #EEE;
}

table.tablex, table.tablex th, table.tablex td {
  border-collapse: collapse;
}

table.tablex th, table.tablex td {
  padding: 0.5em;
  border: 1px solid;
  border-color: #DDD;
}

table.tablex.horinzontal th {
  border-bottom: double;
  font-weight: bold;
}

table.tablex th .stub-type {
  display: block;
  font-style: italic;
  font-weight: normal;
  color: var(--tablex-stub-type-color);
}

table.tablex td.input + td.output {
  border-left: double;
}

table.tablex td.rule-number + td.output {
  border-left: double;
}

table.tablex th.input + th.output {
  border-left: double;
}

table.tablex th.hit-policy {
  border-right: double;
}

table.tablex td.rule-number {
  color: var(--tablex-rule-number-color);
  border-right: double;
  text-align: center;
}

table.tablex.vertical tbody {
  border-top: double;
}

table.tablex.vertical tfoot {
  border-top: double;
}

table.tablex.vertical th.output {
  border-right: double;
}

table.tablex.vertical th.input {
  border-right: double;
}

table.tablex.vertical tfoot {
  background-color: #EEE;
}

table.tablex.vertical td[colspan] {
  text-align: center;
}

table.tablex.vertical tbody th {
  text-align: left;
}

table.tablex.vertical tfoot th {
  text-align: left;
}

.tbx-exp-true {
  font-weight: bold;
}

.tbx-exp-false {
  font-weight: normal;
  font-style: italic;
}

.tbx-exp-number {
  color: var(--tablex-exp-number-color);
}

.tbx-exp-string {
  color: var(--tablex-exp-string-color);
}

.tbx-exp-any {
  color: var(--tablex-exp-any-color);
}

.tbx-exp-list-sep {
  color: var(--tablex-exp-list-sep-color);
}

.tbx-square-bracket {
  color: var(--tablex-square-bracket-color);
}
</style>
<table class="tablex horizontal"><thead><tr><th class=input>user level</th><th class=input>order amount</th><th class=output>discount</th></tr></thead><tbody><tr><td rowspan=2 class="input"><span class=tbx-exp-list><span class='tbx-exp-number tbx-exp-int'>0</span> or <span class='tbx-exp-number tbx-exp-int'>1</span></span></td><td class="input"><span class=tbx-op-comp>&lt;</span><span class=tbx-exp-int><span class='tbx-exp-number tbx-exp-int'>50</span></span></td><td class="output"><span class=tbx-exp-string>10%</span></td></tr><tr><td class="input"><span class=tbx-op-comp>&gt;=</span><span class=tbx-exp-int><span class='tbx-exp-number tbx-exp-int'>50</span></span></td><td class="output"><span class=tbx-exp-string>20%</span></td></tr><tr><td rowspan=3 class="input"><span class=tbx-op-comp>&gt;</span><span class=tbx-exp-int><span class='tbx-exp-number tbx-exp-int'>1</span></span></td><td class="input"><span class=tbx-op-comp>&lt;</span><span class=tbx-exp-int><span class='tbx-exp-number tbx-exp-int'>30</span></span></td><td class="output"><span class=tbx-exp-string>15%</span></td></tr><tr><td class="input"><span class=tbx-op-comp>&lt;</span><span class=tbx-exp-int><span class='tbx-exp-number tbx-exp-int'>50</span></span></td><td class="output"><span class=tbx-exp-string>20%</span></td></tr><tr><td class="input"><span class=tbx-op-comp>&gt;=</span><span class=tbx-exp-int><span class='tbx-exp-number tbx-exp-int'>50</span></span></td><td class="output"><span class=tbx-exp-string>25%</span></td></tr></tbody></table>

## Understanding Decision Tables

Before delving into the practical application, it's crucial to comprehend the structure and formatting of a decision table. The table comprises **inputs**, **outputs**, and specific **rules** that govern the decision-making process. In the context of an Elixir application, the Decision Table is an invaluable resource for handling dynamic business rules.

## A Case Study

Let's consider a scenario where the sales department frequently updates the discount rules on a monthly basis. In such cases, it's imperative to ensure that these rules can be modified without altering the primary application code. Furthermore, the sales team, often unfamiliar with Elixir programming, should be able to update the rules effortlessly. However, although versioning the rules for tracking purposes is beneficial, it is not a mandatory requirement at present.


## Implementing Decision Tables in Elixir

In the context of Elixir, the [Tablex][] library can be helpful for working with decision tables. By utilizing the Tablex library, the decision table can be conveniently represented in a textual format. Here is an example of how the Tablex library can be used within the Elixir environment.

First of all, Tablex can be used to represent the decision table:

```elixir
config = """
  F user.level order.amount || discount
  1 0,1        <50          || "10%"
  2 0,1        >=50         || "20%"
  3 >1         <30          || "15%"
  4 >1         <50          || "20%"
  5 >1         >=50         || "25%"
  """
```

The text can be parsed into a table in memory and used for decision making:

```elixir
user = %{ level: 2 }
order = %{ amount: 10 }

table = Tablex.new(config)

Tablex.decide(table, user: user, order: order)
#=> %{discount: "15%"}
```

The resultant output, in this case, would be `%{discount: "15%"}`.

### Optimizing Performance

While the provided code runs correctly, frequent execution might impact performance. To enhance its efficiency, one can compile the decision table into Elixir code to eliminate the need for string parsing during every execution.

```elixir
code = Tablex.CodeGenerator.generate(table)
```

The generated code will closely resemble the following:

```elixir
case {user, order} do
  {%{level: user_level}, %{amount: order_amount}}
  when is_number(order_amount) and order_amount < 50 and user_level in [0, 1] ->
    %{discount: "10%"}

  # Additional cases ...

end
```

Next, the code can be compiled into an Elixir module with help from [Formular](https://hexdocs.pm/formular/Formular.html#module-compiling-the-code-into-an-elixir-module) library:

```elixir
Formular.compile_to_module!(code, MyDecisionTable)
#=> {:module, MyDecisionTable}
```

With the decision table compiled into an Elixir module, it can be run against the input and return back the output:

```elixir
MyDecisionTable.run(user: %{level: 1}, order: %{amount: 100})
#=> %{discount: "20%"}
```




## Utilizing Decision Tables for Optimization

By incorporating the decision table approach, businesses can enjoy several advantages, including streamlined configuration management, improved rule extraction, and consistent performance levels. Moving forward, we will explore advanced features of the Tablex library and how it aids in dynamic decision table optimization and programmatic modification.

Stay tuned for the upcoming section, where we delve deeper into the diverse functionalities offered by the Tablex library!

[Decision Table]: https://en.wikipedia.org/wiki/Decision_table
[Tablex]: https://github.com/elixir-tablex/tablex
[ETS]: https://www.erlang.org/doc/man/ets.html
