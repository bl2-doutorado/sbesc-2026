# SBESC 2026 - Multi-cloud Intent-based TOSCA Orchestrator

## 🌱 About the Repository

This repository contains the experimental results obtained from the study described in the paper "MITO: A Multicloud Intent-Driven TOSCA Orchestrator for FinOps- and GreenOps-Aware Kubernetes Deployments", submitted to SBESC 2026. 

## Paper abstract

Topology and Orchestration Specification for Cloud Applications (TOSCA) has long been used to describe cloud application topologies and their deployment requirements, but practical multicloud execution still requires substantial engineering to bridge declarative models, optimization decisions, and provider-specific provisioning steps. In previous work, an extended TOSCA profile for FinOps and GreenOps was introduced, along with G-FinOps, an application that uses an Mixed-Integer Linear Programming (MILP) formulation demonstrating the feasibility of multicloud optimization, gererating TOSCA artifacts that can be used to deploy the applications on cloud. However, the internal orchestration engine responsible for operationalizing those ideas remained a black box. This paper fills that gap by presenting MITO, the Multicloud Intent-driven TOSCA Orchestrator, a runtime engine that transforms declarative TOSCA specifications into coordinated Terraform and Helm executions across managed Kubernetes clusters across multiple cloud providers. MITO is integrated with G-FinOps, where an OR-Tools-based MILP optimizer selects providers, placement strategies, machine models, and replica distributions under cost, availability, and carbon-aware objectives. The orchestrator then consumes the resulting Cloud Service Archive (CSAR) release, translates it into executable infrastructure and workload artifacts, maintains state through a reconciliation loop, and supports periodic drift correction, reoptimization, and auto-healing. This paper details the architecture, execution workflow, plugin-based backend abstraction, and GitOps-inspired state management of MITO, positioning it as a practical runtime realization of intent-driven TOSCA orchestration for FinOps- and GreenOps-aware multicloud deployments.


## Repository structure

It is structured as follows:


```
.
<!-- ├── benchmarks/                           # Raw benchmark data and logs -->
└── README.md                             # This document
└── tosca-csars                           # TOSCA CSARs used in the experiments
    ├── single-cloud-oci
    ├── two-clouds-distributed
    └── two-clouds-mirrored
└── experiment-results                    # Results of the experiments
    ├── two-clouds-distributed
    └── two-clouds-mirrored

```


## LICENSE

[MIT LICENSE](LICENSE).