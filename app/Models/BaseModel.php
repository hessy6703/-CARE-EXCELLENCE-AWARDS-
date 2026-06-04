<?php
/**
 * CEAMS - Base Model Class
 * Parent class for all models
 */

namespace App\Models;

use Core\Database;

class BaseModel
{
    protected $db;
    protected $table;
    protected $fillable = [];
    protected $timestamps = true;

    public function __construct()
    {
        $this->db = new Database([
            'host' => $_ENV['DB_HOST'] ?? 'localhost',
            'database' => $_ENV['DB_NAME'] ?? 'ceams',
            'user' => $_ENV['DB_USER'] ?? 'root',
            'password' => $_ENV['DB_PASS'] ?? ''
        ]);
    }

    /**
     * Get all records
     */
    public function all()
    {
        $sql = "SELECT * FROM {$this->table}";
        $this->db->query($sql);
        return $this->db->resultSet();
    }

    /**
     * Find record by ID
     */
    public function find($id)
    {
        $sql = "SELECT * FROM {$this->table} WHERE id = :id";
        $this->db->query($sql);
        $this->db->bind(':id', $id);
        return $this->db->single();
    }

    /**
     * Find by specific column
     */
    public function findBy($column, $value)
    {
        $sql = "SELECT * FROM {$this->table} WHERE {$column} = :value";
        $this->db->query($sql);
        $this->db->bind(':value', $value);
        return $this->db->single();
    }

    /**
     * Create new record
     */
    public function create($data)
    {
        $columns = implode(', ', array_keys($data));
        $placeholders = implode(', ', array_map(fn($col) => ':' . $col, array_keys($data)));

        if ($this->timestamps) {
            $columns .= ', created_at, updated_at';
            $placeholders .= ', NOW(), NOW()';
        }

        $sql = "INSERT INTO {$this->table} ({$columns}) VALUES ({$placeholders})";
        $this->db->query($sql);

        foreach ($data as $key => $value) {
            $this->db->bind(':' . $key, $value);
        }

        if ($this->db->execute()) {
            return $this->db->lastInsertId();
        }
        return false;
    }

    /**
     * Update record
     */
    public function update($id, $data)
    {
        $updates = implode(', ', array_map(fn($col) => "{$col} = :{$col}", array_keys($data)));

        if ($this->timestamps) {
            $updates .= ', updated_at = NOW()';
        }

        $sql = "UPDATE {$this->table} SET {$updates} WHERE id = :id";
        $this->db->query($sql);

        foreach ($data as $key => $value) {
            $this->db->bind(':' . $key, $value);
        }
        $this->db->bind(':id', $id);

        return $this->db->execute();
    }

    /**
     * Delete record
     */
    public function delete($id)
    {
        $sql = "DELETE FROM {$this->table} WHERE id = :id";
        $this->db->query($sql);
        $this->db->bind(':id', $id);
        return $this->db->execute();
    }

    /**
     * Count records
     */
    public function count($where = null)
    {
        $sql = "SELECT COUNT(*) as count FROM {$this->table}";
        if ($where) {
            $sql .= " WHERE {$where}";
        }
        $this->db->query($sql);
        $result = $this->db->single();
        return $result['count'] ?? 0;
    }

    /**
     * Get database instance
     */
    public function db()
    {
        return $this->db;
    }
}
