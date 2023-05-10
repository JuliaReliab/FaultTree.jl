# FaultTree

[![Build Status](https://travis-ci.com/okamumu/FaultTree.jl.svg?branch=master)](https://travis-ci.com/okamumu/FaultTree.jl)
[![Coverage](https://codecov.io/gh/okamumu/FaultTree.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/okamumu/FaultTree.jl)
[![Coverage](https://coveralls.io/repos/github/okamumu/FaultTree.jl/badge.svg?branch=master)](https://coveralls.io/github/okamumu/FaultTree.jl?branch=master)

FaultTree.jl provides a tool to compute the probability based on fault trees.

## Installation

This is not in the official package of Julia yet. Please run the following command to install it.
```julia
using Pkg;
Pkg.add(PackageSpec(url="https://github.com/JuliaReliab/FaultTree.jl.git"))
```

## Load module

Load the module:
```
using FaultTree
```

## What is Fault Tree?

The fault tree is a probabilistic model to compute the system failure probability based on the relation between the system failure and component failures. The system failure is placed as the top event, and we write the scenario what are the condition that causes the top event. For example, the system consists of two components, and the system failure occurs only when both components are failed. Then the system failure event is decomposed into two causal events; Each of component is failed. The condition is represented by a combination of logical operatiors such as AND and OR, which are called AND and OR gates. The following figure represents the typical fault tree using AND/OR gates.

![](./docs/figs/ft1.png)

In the example, there are three components; CPU, Memory and Software. The system failure occurs in the following cases.

| CPU | Memory | Software | System Failure |
| :-: | :-: | :-: | :-: |
| X | X | X | X |
| X | - | X | X |
| - | X | X | X |
| - | -| X | - |
| X | X | - | - |
| X | -| - | - |
| - | X | - | - |
| - | -| - | - |

One of the advantage of fault tree analysis is to reveal the minimum failure patterns causing the system failure, called the minimal cut sets (MCS). In the example, the MCS are

| CPU | Memory | Software |
| :-: | :-: | :-: |
| X | - | X |
| - | X | X |

Based on the above, we recognize the failure of Software is critical for the system failure.

Also, one of the purpose of fault tree is to compute the occurrence probability of top event. When $p_A$, $p_B$ and $p_C$ are the failure probabilities of CPU, Memory and Software, the probability of system failure becomes
$$
p_S = (1 - (1 - p_A) (1 - p_B)) p_C
$$
This formula is based on the causal relation in the fault tree.

## Building a fault tree

The fault tree consists of events and gates. Each gate has several gates and/or events as children. For the time being, the tool can use the following events and gates.

- Events
    - Basic event
    - Repeat event
    - Intermediate event
- Gates
    - AND gate
    - OR gate
    - k-out-of-n gate

### Basic event

The basic event is a bottom node of fault tree (leaf node), and represents an event such as a component failure. In the diagram, it can be drawn as a circle. The difference between basic and repeat events appers when the nodes having the same label are placed as two or more leaf nodes. In the case of basic event, they are exactly copied, i.e., the instances of leaf nodes are different. Therefore, even if one event occurs, it does not affect another one that is copied.

For example, we consider the following fault tree having two basic events.

![](./docs/figs/ft2.png)

The bottom nodes have the same label A. However, they are different instances. Let $p_A$ be the failure probability of A. Since the probability of system failure is the probability that two components are failed, it becomes
$$
p_S = p_A p_A
$$

### Repeat event

The repeat event is a bottom node of fault tree (leaf node), and represents an event such as a component failure. In the diagram, similar to the basic event, it can be drawn as a circle (sometimes, it is distiguished as a coloer). The difference between basic and repeat events appers when the nodes having the same label are placed as two or more leaf nodes. In the case of repeat event, they are exactly same instances. Therefore, when one event occurs, other copied events are also happen.

For example, we consider the following fault tree having two repeat events.

![](./docs/figs/ft3.png)

The bottom nodes have the same instance. Let $p_A$ be the failure probability of A. Since the probability of system failure is the probability that one component A is failed, it becomes
$$
p_S = p_A
$$

### Intermediate event



### AND gate

### OR gate

### k-out-of-n gate

