package com.hospital.dashboard.controller;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.web.bind.annotation.*;

import java.util.List;

public abstract class BaseController<T, ID> {

    protected abstract JpaRepository<T, ID> getRepository();

    @GetMapping
    public List<T> getAll() {
        return getRepository().findAll();
    }

    @PostMapping
    public T create(@RequestBody T entity) {
        return getRepository().save(entity);
    }

    @GetMapping("/{id}")
    public T getOne(@PathVariable ID id) {
        return getRepository().findById(id).orElse(null);
    }

    @DeleteMapping("/{id}")
    public void delete(@PathVariable ID id) {
        getRepository().deleteById(id);
    }

    // Update usually requires specific logic per entity, so we leave it abstract or
    // override it
}
