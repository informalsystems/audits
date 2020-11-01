# DDC Audit Process

This is an initial proposal on the audit process organization. In the best Informal tradition of having at least two D's in the process names, we continue the VDD/DDV line, and name our process **DDC**, by the names of the process phases: **D**ecomposition, **D**iscovery, **C**onsolidation. 

## Assumptions

1. We want to deliver the best possible value for the customer as a result of our audit. The audit report itself, while useful, is not enough; what we want to provide is a **set of reusable artifacts**. Those artefacts could be TLA+ models, unit tests, subsystem/integration tests, test drivers, fuzz corpuses, etc. This will help both the customer to better understand and maintain the quality of their system; it will help informal, as these artifacts will serve us as hooks into the customer's CI, and it's likely that they will want to maintain them as a paid service; finally, this will help the whole community to disseminate the best quality assurance practices based on formal verification. 

2. We agree that we use TLA+ as our main knowledge communication language. While English specs and reports are very good for obtaining initial understanding; they are not precise enough to avoid ambiguities, not to mention to serve as the basis for automated solutions. Thus, we assume that TLA+ should be an actively maintained skill of every team member.

## Scope / Time / Team

The target **system** is likely to be a complex and large software platform. Thus, we aim to decompose it into relatively independent **subsystems**, such that each subsystem is either loosely coupled with the others, or it resides on another level of the system stack. We further aim to decompose each subsystem into **subsystem units** manageable by a smaller group of 1-3 persons; the reason for that being higher work efficiency within small groups. 

We propose to split the whole **audit period** into **sprints**, and each sprint into **phases**. A duration for the audit period could be 1-3 months, depending on the system size and complexity; sprints we propose to limit to 1 week, the duration of the three sprint phases will then be 1/3/1 days.

During the audit **period** we analyse the whole target system; during each **sprint** -- one subsystem.

We propose to split each sprint into **three phases**: system **decomposition**, knowledge **discovery**, and artifact **consolidation** (hence the name **DDC**). Each phase should end up with a set of artifacts, as described below. 

The three phases should also be applied to the whole audit period; while the artifacts after sprint phases describe subsystem units/subsystems; the artifacts after audit phases describe subsystems or the whole system.  

The **audit team** is likely to consist of 5-7 people, preferably mixing persons with the expertise in various areas. For each sprint phase the audit team splits itself into **audit groups** of 1-3 persons, each group addressing a separate subsystem unit. It is imaginable that the period phases could be performed by a separate **system audit group** of 1-2 people, their goal being the integration of the knowledge about individual subsystems into the coherent knowledge about the whole system.   

It is to be understood that the proposed scheme can be flexed to fit particular circumstances. E.g., the sprint phases could be made 1/2/2 days, when the interactions between subsystem units are trickier than the units themselves; or a separate sprint could be devoted to analyze the interactions of a certain set of subsystems; or a separate sprint could be also devoted to the consolidation of knowledge about the whole system.



## Decomposition

### Goal

Decompose the analysis target into smaller, individually manageable units, and discover their relationships.

### Outcomes

* A model of the target subsystem that splits it into several units, specifies their most important interfaces, and their relationships. 
* Shared understanding of the subsystem domain within the audit group, and agreement about the decomposition model. 
* Decide on the teams addressing each decomposition units.

### Procedure 

The initial decomposition is performed by small group or a single person, preferably having the most domain knowledge. They construct the initial model of the system as described above, and present it to the whole audit group. The goal of this initial discussion is to develop the shared and agreed upon understanding of the domain by all audit group members. During the discussion the other group members should try to develop their understanding by challenging the decomposers' decisions. It is likely that the discussion will allow to refine the decomposition model.



## Discovery

### Goal

Develop a deep understanding of each subsystem unit. Codify the understanding in a unit model, the textual description, and other artifacts.

### Outcomes

* The model of the subsystem unit.
* Other artifacts, such as unit tests, test drivers, fuzz corpuses, etc. 
* List of findings/bugs within the unit.
* Precise dependencies from other units.
* Textual description of the unit functionality, which can be used both for informing the other team members and for the audit report.

### Procedure 

The subsystem unit is thoroughly reviewed by a small group of 1-3 persons with the most suitable qualifications for that task. Their main goal is to develop a mental model of the unit, and codify this model in TLA+. Other outcomes, while highly desirable, play a secondary role. During the phase duration the audit group meets on a by-need basis; with probably short synchonizations each day. The group should aim at codifying the unit model right away, as this could result in useful synergies with other audit groups, when they study the dependencies of their unit from the others.




## Consolidation

### Goal

Consolidate individual knowledge pieces obtained by each audit group into a coherent model of the subsystem. The result should be preferably the formal subsystem model; usable e.g. for subsystem/integration tests. Find possible issues resulting from subsystem unit interactions. Accordingly, when applied at the system level, find issues from the interactions of subsystems. 

### Outcomes

* Subsystem model
* Other artifacts, such as subsystem tests, test drivers, fuzz corpuses, etc. 
* List of findings/bugs resulting from interactions between subsystem units.
* Precise dependencies from other subsystems.
* Textual description of the subsystem functionality, which can be used for the audit report.

### Procedure 

This phase happens when individual audit groups have gathered enough understanding and knowledge of their respective subsystem units. We assume that this has helped already to discover certain findings or bugs for each unit. This phase happens in intensive discussions either of the whole audit team, or of certain combinations of audit groups whose units actively interact with each other. Each audit group is supposed to present their model and findings; while others strive to internalize the presented knowledge and to challenge the presentation from their own point of view. It is anticipated that the subsystem units models will be refined as a result of the discussion. The main goal of the discussions is to obtain a coherent subsystem model, composed from subsystem units models in a modular way. Ideally, this model will  then be used to derive other artifacts, such as tests/test drivers/fuzzers; but it's possible that this activity is left either for another sprint or to the system audit group.